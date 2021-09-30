# Recotem Batch Example

## Overview

This repository is a reference implementation for Batch processing to create a model for Recotem.

## Getting Started

You can clone this repository:

```
$ git clone https://github.com/codelibs/recotem-batch-example.git
```

and modify files for your project.

- `app/run.sh`: a main script file
- `app/create_data.*`: script files to create training data
- `app/save_model.sh`: a script file to save/upload a model file

### Build Docker Image

```
$ docker-compose -f docker-compose.yml build
```

### Run Batch Process

```
$ docker-compose -f docker-compose.yml up --abort-on-container-exit
```


## Others

### Deploy On AWS ECS

This repository contains a manifest file for AWS Copilot.
You can deploy this batch project as Schedule Task for ECS.

```
$ copilot init -a recotem-batch-example -d ./Dockerfile -n backend --schedule "@daily" -t "Scheduled Job" --deploy
```

