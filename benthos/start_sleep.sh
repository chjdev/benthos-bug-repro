#!/bin/sh
echo "sleeping"
sleep 15
echo "starting"
/benthos -c /etc/benthos/config_sleep.yaml
