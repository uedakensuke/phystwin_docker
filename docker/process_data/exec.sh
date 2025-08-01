#!/bin/bash
SERVICE="process_data"
UP=$(docker compose ps --services --status=running $SERVICE)

if [ "$UP" != "$SERVICE" ]; then
    docker compose up --no-build -d
    if [ $? -ne 0 ]; then
        echo "先にイメージをbuildしてください"
        exit 1
    fi
fi

# conda環境を有効にする為に-iをつける
echo "$*"
docker compose exec -u "$(id -u $USER):$(id -g $USER)" -e DISPLAY -it $SERVICE bash -i -c "$*"