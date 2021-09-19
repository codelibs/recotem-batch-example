#!/bin/bash

base_dir=/opt/app
csv_file=$1

echo "creating ${csv_file}"
python ${base_dir}/create_data.py "${csv_file}"
if [[ ! -f ${csv_file} ]] ; then
  echo "no csv file."
  exit 1
fi
ls -l "${csv_file}"
