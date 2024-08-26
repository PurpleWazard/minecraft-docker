#!/bin/bash

echo "$DOMAIN"
echo "$TOKEN"
echo "$INTERVAL"

if [ -z "$DOMAIN" ] || [ -z "$TOKEN" ] || [ -z "$INTERVAL" ]; then
    echo "not all env vars are set .. exiting"
    exit 1
fi

while true; do
    output=$(curl -sS "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=")
    echo "$output --- $(date)"
    sleep ${INTERVAL}
done

exit 0
