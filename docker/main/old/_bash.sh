#!/bin/bash
IMG_TAG="phystwin-main"
CONTAINER_NAME="phystwin-main-$USER"

docker start $CONTAINER_NAME
docker exec -u "$(id -u $USER):$(id -g $USER)" -e DISPLAY -it $CONTAINER_NAME bash