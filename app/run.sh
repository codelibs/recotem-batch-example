#!/bin/bash

base_dir=/opt/app
max_wait=1800
tmp_file=/tmp/recotem.$$

#
# start recotem
#
/bin/bash /app/start.sh &

count=0
ret=1
while [[ ${count} -lt ${max_wait} && ${ret} != "0" ]] ; do
  curl -s "${RECOTEM_URL}/api/ping/" -o /dev/null
  ret=$?
  count=$((count+1))
  sleep 1
done

if [[ ${ret} != "0" ]] ; then
  echo "Recotem does not work."
  exit 1
fi

#
# create config for recotem-cli
#
mkdir -p "$HOME/.recotem"
echo "url: ${RECOTEM_URL}" > "$HOME/.recotem/config.yaml"

#
# create csv file
#
csv_file=${base_dir}/train.csv.gz
if ! /bin/bash ${base_dir}/create_data.sh ${csv_file}; then
  echo "failed to create csv file."
  exit 1
fi

#
# train on recotem
#
project_name=recotem$(date +%s)

echo "log in to recotem"
if ! recotem login --username "${RECOTEM_USERNAME}" --password "${RECOTEM_PASSWORD}" > ${tmp_file}; then
  cat ${tmp_file}
  exit 1
fi

time_column_opt=
if [[ "x$TIME_COLUMN" != "x" ]] ; then
  time_column_opt="--time-column ${TIME_COLUMN}"
fi
echo "creating ${project_name} project"
if ! recotem project create --name "${project_name}" --user-column "${USER_COLUMN}" --item-column "${ITEM_COLUMN}" \
     ${time_column_opt} > ${tmp_file}; then
  cat ${tmp_file}
  exit 1
fi

project_id=$(awk '{ print $1 }' ${tmp_file})
echo "project: ${project_id}"

echo "uploading ${csv_file}"
if ! recotem training-data upload --project "${project_id}" --file ${csv_file} > ${tmp_file}; then
  cat ${tmp_file}
  exit 1
fi

data_id=$(awk '{ print $1 }' ${tmp_file})
echo "data: ${data_id}"

echo "creating split config"
if ! recotem split-config create --heldout-ratio "${HELDOUT_RATIO}" --test-user-ratio "${TEST_USER_RATIO}" > ${tmp_file}; then
  cat $tmp_file
  exit 1
fi

split_id=$(awk '{ print $1 }' ${tmp_file})
echo "split: ${split_id}"

echo "creating evaluation config"
if ! recotem evaluation-config create --cutoff "${CUTOFF}" --target-metric "${TARGET_METRIC}" > ${tmp_file}; then
  cat $tmp_file
  exit 1
fi

eval_id=$(awk '{ print $1 }' ${tmp_file})
echo "evaluation: $eval_id"

echo "training"
if ! recotem parameter-tuning-job create --data "${data_id}" --split "${split_id}" --evaluation "${eval_id}" \
     --n-tasks-parallel "${N_TASKS_PARALLEL}" --n-trials "${N_TRIALS}" --memory-budget "${MEMORY_BUDGET}" > ${tmp_file}; then
  cat $tmp_file
  exit 1
fi

job_id=$(awk '{ print $1 }' ${tmp_file})
echo "job: $job_id"

count=0
ret=running
while [[ $count -lt ${max_wait} && "${ret}" = "running" ]] ; do
  if recotem parameter-tuning-job list --id "${job_id}" > ${tmp_file}; then
    status=$(awk '{ print $3 }' ${tmp_file})
    if [[ ${status} = "SUCCESS" ]] || [[ ${status} = "FAILURE" ]] ; then
      ret="done"
    fi
  fi
  count=$((count+1))
  sleep 10
done

model_id=$(awk '{ print $4 }' ${tmp_file})
echo "model: $model_id"

if [[ "$model_id" = "<NA>" ]] ; then
  exit 1
fi

echo "downloading model"
if ! recotem trained-model download --id "${model_id}" --output "${MODEL_PATH}" > ${tmp_file}; then
  cat $tmp_file
  exit 1
fi

#
# save model file
#
if ! /bin/bash ${base_dir}/save_model.sh "${MODEL_PATH}"; then
  echo "failed to save model file."
  exit 1
fi
