#!/bin/bash

if [ -n "$DOMAIN" ] || [ -n "$TOKEN" ] || [ -n "$INTERVAL" ]; then
    echo "not all env vars are set .. exiting"
    exit 1

while true; do
    curl "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip="
    sleep ${INTERVAL}
done
