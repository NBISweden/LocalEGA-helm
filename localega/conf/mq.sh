#!/bin/bash

set -e
set -x

[[ -z "${CEGA_MQ_HOST}" ]] || [[ -z "${CEGA_MQ_PASSWORD}" ]] || [[ -z "${CEGA_PORT}" ]] || [[ -z "${CEGA_VHOST}" ]] || [[ -z "${CEGA_USERNAME}" ]] && echo 'Environment CEGA_CONNECTION is empty' 1>&2 && exit 1
export CEGA_CONNECTION="amqps://$CEGA_USERNAME:$CEGA_MQ_PASSWORD@$CEGA_MQ_HOST:$CEGA_PORT/$CEGA_VHOST"

# Initialization
cp --remove-destination /temp/rabbitmq.config /etc/rabbitmq/rabbitmq.config
cp --remove-destination /temp/defs.json /etc/rabbitmq/defs.json
rabbitmq-plugins enable --offline rabbitmq_federation
rabbitmq-plugins enable --offline rabbitmq_federation_management
rabbitmq-plugins enable --offline rabbitmq_shovel
rabbitmq-plugins enable --offline rabbitmq_shovel_management

chmod 640 /etc/rabbitmq/rabbitmq.config
chmod 640 /etc/rabbitmq/defs.json

# Problem of loading the plugins and definitions out-of-orders.
# Explanation: https://github.com/rabbitmq/rabbitmq-shovel/issues/13
# Therefore: we run the server, with some default confs
# and then we upload the cega-definitions through the HTTP API

# We cannot add those definitions to defs.json (loaded by the
# management plugin. See /etc/rabbitmq/rabbitmq.config)
# So we use curl afterwards, to upload the extras definitions
# See also https://pulse.mozilla.org/api/

# dest-exchange-key is not set for the shovel, so the key is re-used.

# For the moment, still using guest:guest
cat > /etc/rabbitmq/defs-cega.json <<EOF
{"parameters":[{"value": {"src-uri": "amqp://",
				"src-exchange": "cega",
				"src-exchange-key": "#",
				"dest-uri": "${CEGA_CONNECTION}",
				"dest-exchange": "localega.v1",
				"add-forward-headers": false,
				"ack-mode": "on-confirm",
				"delete-after": "never"},
				"vhost": "/",
		"component": "shovel",
		"name": "to-CEGA"},
			{"value": {"src-uri": "amqp://",
				"src-exchange": "lega",
				"src-exchange-key": "completed",
				"dest-uri": "amqp://",
				"dest-exchange": "cega",
				"dest-exchange-key": "files.completed",
				"add-forward-headers": false,
				"ack-mode": "on-confirm",
				"delete-after": "never"},
		"vhost": "/",
		"component": "shovel",
		"name": "CEGA-completion"},
			{"value":{"uri":"${CEGA_CONNECTION}",
				"ack-mode":"on-confirm",
				"trust-user-id":false,
				"queue":"v1.files"},
		"vhost":"/",
		"component":"federation-upstream",
		"name":"CEGA-files"},
			{"value":{"uri":"${CEGA_CONNECTION}",
				"ack-mode":"on-confirm",
				"trust-user-id":false,
				"queue":"v1.stableIDs"},
		"vhost":"/",
		"component":"federation-upstream",
		"name":"CEGA-ids"}],
	"policies":[{"vhost":"/",
				"name":"CEGA-files",
				"pattern":"v1.files",
				"apply-to":"queues",
				"definition":{"federation-upstream":"CEGA-files"},
				"priority":0},
				{"vhost":"/",
				"name":"CEGA-ids",
				"pattern":"v1.stableIDs",
				"apply-to":"queues",
				"definition":{"federation-upstream":"CEGA-ids"},
				"priority":0}]
}
EOF
chmod 640 /etc/rabbitmq/defs-cega.json

# And...cue music
# chown -R rabbitmq /var/lib/rabbitmq

{ # Spawn off
	sleep 5 # Small delay first

	# Wait until the server is ready (because we don't nave netcat we use wait on the pid)
	ROUND=30
	until rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit@${HOSTNAME}.pid || ((ROUND<0))
	do
	sleep 1
	$((ROUND--))
	done
	rabbitmqadmin import /etc/rabbitmq/defs-cega.json
	((ROUND<0)) && echo "Central EGA connections *_not_* loaded" 2>&1 && exit 1
	echo "Central EGA connections loaded"
} &

exec rabbitmq-server