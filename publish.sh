#!/usr/bin/env bash

BUILDER_NAME=$(docker buildx create) && docker buildx use $BUILDER_NAME
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:5.18.3 .
docker buildx build --push --platform linux/arm64,linux/amd64 --tag andriykalashnykov/activemq:latest .
