#!/usr/bin/env bash

docker rmi --force andriykalashnykov/activemq:5.18.3
docker rmi --force  andriykalashnykov/activemq:latest

docker build -t andriykalashnykov/activemq:5.18.3 .
docker build -t andriykalashnykov/activemq:latest .

