#!/bin/bash
echo "SUDO_GID=$(getent group sudo | cut -d: -f3)" > .env
echo "VGLUSERS_GID=$(getent group vglusers | cut -d: -f3)" >> .env

docker compose build --build-arg USER=$USER --build-arg UID="$(id -u $USER)" --build-arg GID="$(id -g $USER)"
