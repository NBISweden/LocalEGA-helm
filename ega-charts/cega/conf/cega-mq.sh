#!/bin/bash

set -e

# Initialization
rabbitmq-plugins enable --offline rabbitmq_federation
rabbitmq-plugins enable --offline rabbitmq_federation_management
rabbitmq-plugins enable --offline rabbitmq_shovel
rabbitmq-plugins enable --offline rabbitmq_shovel_management

cp --remove-destination /temp/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
cp --remove-destination /temp/defs.json /etc/rabbitmq/defs.json
chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf
chmod 640 /etc/rabbitmq/rabbitmq.conf
chown rabbitmq:rabbitmq /etc/rabbitmq/defs.json
chmod 640 /etc/rabbitmq/defs.json

exec rabbitmq-server