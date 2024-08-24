#!/bin/bash
CONFIG_DIR="/etc/wireguard"
WG_CONFIG="$CONFIG_DIR/wg0.conf"
PUB_FILE="$CONFIG_DIR/public"
PRI_FILE="$CONFIG_DIR/private"
CLIENT_KEY="$CLIENT_KEY"

echo "$KEY_PRIVATE and $KEY_PUBLIC"

# Check if the key files exist
if [ ! -f "$PUB_FILE" ] || [ ! -f "$PRI_FILE" ]; then

    # Generate new keys if private key is not provided
    if [ -z "$KEY_PRIVATE" ]; then
        umask 077
        KEY_PRIVATE=$(wg genkey)
        KEY_PUBLIC=$(echo "$KEY_PRIVATE" | wg pubkey)
    else
        # Use provided private key to generate public key
        KEY_PUBLIC=$(echo "$KEY_PRIVATE" | wg pubkey)
    fi

    # Save keys to files
    echo "$KEY_PRIVATE" > "$PRI_FILE"
    echo "$KEY_PUBLIC" > "$PUB_FILE"

elif [ -z "$KEY_PUBLIC" ]; then
    KEY_PUBLIC=$(cat "$PUB_FILE")

elif [ -z "$KEY_PRIVATE" ]; then
    KEY_PRIVATE=$(cat "$PRI_FILE")

else

    # Check if provided keys differ from stored keys
    if [ "$KEY_PRIVATE" != "$(cat "$PRI_FILE")" ]; then
        echo "$KEY_PRIVATE" > "$PRI_FILE"
    fi

    if [ "$KEY_PUBLIC" != "$(cat "$PUB_FILE")" ]; then
        echo "$KEY_PUBLIC" > "$PUB_FILE"
    fi

fi

echo "Private key: $KEY_PRIVATE and file: $(cat $PRI_FILE)"
echo "public key: $KEY_PUBLIC and file: $(cat $PUB_FILE)"

echo "client key: $CLIENT_KEY"


cat <<EOF > "$WG_CONFIG"
[Interface]
PrivateKey = $KEY_PRIVATE
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

# Keep the container running
tail -f /dev/null

