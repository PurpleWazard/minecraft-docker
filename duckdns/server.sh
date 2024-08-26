#!/bin/bash

echo "$DOMAIN"
echo "$TOKEN"
echo "$INTERVAL"

if [ -n "$DOMAIN" ] || [ -n "$TOKEN" ] || [ -n "$INTERVAL" ]; then
    echo "not all env vars are set .. exiting"
    exit 1
fi

while true; do
    curl "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip="
    sleep ${INTERVAL}
done

exit 0
