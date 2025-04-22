#!/bin/bash
IMG_TAG="phystwin-main"
CONTAINER_NAME="phystwin-main-$USER"

docker start $CONTAINER_NAME
docker exec -u 0 -e DISPLAY -it $CONTAINER_NAME bash