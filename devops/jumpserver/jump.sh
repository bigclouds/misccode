#!/bin/bash

SECRET_KEY=2hcr7TQ4Sg0UxRj28t7GHreR9vA4Cuv4xc1jCQNEfd25br8Qyb
BOOTSTRAP_TOKEN=qkxfV7VI8kZDAb95
docker run --name jms_all -d -p 8090:80 -p 2223:2222 -e SECRET_KEY=$SECRET_KEY -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN jumpserver/jms_all:1.4.8
