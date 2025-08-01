#!/bin/bash
SERVICE="main"
UP=$(docker compose ps --services --status=running $SERVICE)

if [ "$UP" != "$SERVICE" ]; then
    docker compose up --no-build -d
    if [ $? -ne 0 ]; then
        echo "先にイメージをbuildしてください"
        exit 1
    fi
fi

docker compose exec -e DISPLAY -it $SERVICE bash