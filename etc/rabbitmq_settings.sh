#!/bin/sh

#
# RabbitMQ network name
#
RABBITMQ_NETWORK_NAME="rabbits"

#
# RabbitMQ container image
#
RABBITMQ_CONTAINER_IMAGE="harbor.ddtechcg.com/rabbitmq/rabbitmq:3.8-management"

#
# RabbitMQ Erlang cookie
#
RABBITMQ_ERLANG_COOKIE="WIWVHCDTCIUAWANLMQAW"


#
# RabbitMQ instances and ports
#
# NOTE:
# 1. a delimiter "~" between instances
#
RABBITMQ_INSTANCES="rabbit-1:8081~rabbit-2:8082~rabbit-3:8083"

