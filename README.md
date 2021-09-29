# Recotem Batch Example

## Build Docker Image

```
$ docker-compose -f docker-compose.yml build
```

### Create Model

```
$ docker-compose -f docker-compose.yml up --abort-on-container-exit
```

### Deploy On AWS ECS

```
$ copilot init -a recotem-batch-example -d ./Dockerfile -n backend --schedule "@daily" -t "Scheduled Job" --deploy
```

