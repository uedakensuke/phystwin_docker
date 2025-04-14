#!/bin/bash
IMG_TAG="phystwin"
CONTAINER_NAME="phystwin-$USER"

docker start $CONTAINER_NAME
docker exec -u 0 -e DISPLAY -it $CONTAINER_NAME bash