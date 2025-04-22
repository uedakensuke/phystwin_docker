#!/bin/bash
IMG_TAG="phystwin-main"
CONTAINER_NAME="phystwin-main-$USER"
ENV_NAME="phystwin-main"

################# clean up
echo "---- stopping the old container"
docker stop $CONTAINER_NAME
echo "---- removeing the old container"
docker rm $CONTAINER_NAME
# echo "---- removeing the old image"
# docker rmi $IMG_TAG
#################

################# build image
echo "---- building a new image"
docker build --build-arg USER=$USER --build-arg UID="$(id -u $USER)" --build-arg GID="$(id -g $USER)" -t $IMG_TAG ..

if [ $? -ne 0 ]; then
    echo "ビルドに失敗しました"
    exit 1
fi

################# create container
echo "---- creating a new container"
userid="$(id -u)"
groups="$(id --real --groups $USER)"
add_groups=$(for t in $groups;do echo "--group-add=$t"; done)

docker create -it\
    $add_groups\
    --env="DISPLAY"\
    --env="USER"\
    --env=QT_X11_NO_MITSHM=1\
    --env NVIDIA_DRIVER_CAPABILITIES=all\
    --workdir="/home/$USER"\
    --volume="$PWD/../mount:/home/$USER/mount"\
    --volume="/home/$USER/.Xauthority:/home/$USER/.Xauthority"\
    --volume="/etc/group:/etc/group:ro"\
    --volume="/etc/passwd:/etc/passwd:ro"\
    --volume="/etc/shadow:/etc/shadow:ro"\
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro"\
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw"\
    --net=host\
    --gpus=all\
    --name $CONTAINER_NAME\
    $IMG_TAG\
    bash

if [ $? -ne 0 ]; then
    echo "コンテナ作成に失敗しました"
    exit 1
fi

docker start $CONTAINER_NAME
