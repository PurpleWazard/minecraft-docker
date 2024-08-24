#!/bin/bash

CONFIG_DIR="/etc/wireguard"
WG_CONFIG="$CONFIG_DIR/wg0.conf"
PUB_FILE="$CONFIG_DIR/public"
PRI_FILE="$CONFIG_DIR/private"
KEY_PUBLIC="$KEY_PUBLIC"
KEY_PRIVATE="$KEY_PRIVATE"

CLIENT_KEY="$CLIENT_KEY"



if [ ! -f "$PUB_FILE" ] && [ ! -f "$PRI_FILE" ]; then

    if [ -z "$KEY_PRIVATE" ]; then
        umask 077
        $KEY_PRIVATE="$(wg genkey)"
        $KEY_PUBLIC="$(wg pubkey < $KEY_PRIVATE)"
    else
        $KEY_PUBLIC="$(wg pubkey < $KEY_PRIVATE)"
    fi


    echo "$KEY_PRIVATE" > "$PRI_FILE"
    echo "$KEY_PUBLIC" > "$PUB_FILE"

else 

    if [ ! "$KEY_PRIVATE" == $(cat "$PRI_FILE") ]; then
        echo "$KEY_PRIVATE" > "$PRI_FILE"

    elif [ ! "$KEY_PUBLIC" == $(cat "$PUB_FILE") ]; then
        echo "$KEY_PUBLIC" > "$PUB_FILE"
    fi

fi

    echo "Private key: $KEY_PRIVATE"
    echo "PUBLIC key: $KEY_PUBLIC"


cat <<EOF > "$WG_CONFIG"
[Interface]
PrivateKey = $(cat $PRIVATE_KEY_FILE)
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = $CLIENT_KEY
AllowedIPs = 10.0.0.2/32
EOF


# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Start the WireGuard interface
wg-quick up wg0

# Create log file if it doesn't exist
if [ ! -f "$WG_LOG_FILE" ]; then
    touch "$WG_LOG_FILE"
    echo "this is the log file" >> "$WG_LOG_FILE"
fi

echo "server public key: $(cat $PUBLIC_KEY_FILE)"

# Keep the container running
tail -f /dev/null

