#!/usr/bin/env bash

docker rmi andriykalashnykov/activemq:5.18.3
docker rmi andriykalashnykov/activemq:latest

docker build -t andriykalashnykov/activemq:5.18.3 .
docker build -t andriykalashnykov/activemq:latest .

BUILDER_NAME=$(docker buildx create) && docker buildx use $BUILDER_NAME
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:5.18.3 .
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:latest .
