#!/bin/bash
IMG_TAG="phystwin"
CONTAINER_NAME="phystwin-$USER"

docker start $CONTAINER_NAME
docker exec -e DISPLAY -it $CONTAINER_NAME bash