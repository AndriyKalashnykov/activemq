#!/usr/bin/env bash

docker rmi andriykalashnykov/activemq:5.18.3
docker build -t andriykalashnykov/activemq:5.18.3 .