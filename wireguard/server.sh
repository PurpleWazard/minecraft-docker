#!/bin/bash

CONFIG_DIR="/etc/wireguard"
PRIVATE_KEY_FILE="$CONFIG_DIR/privatekey"
PUBLIC_KEY_FILE="$CONFIG_DIR/publickey"
WG_CONFIG="$CONFIG_DIR/wg0.conf"
WG_LOG_FILE="/etc/wireguard/wireguard.log"
CLIENT_KEY=$(cat /run/secrets/client_pub_key)

# Check if CLIENT_KEY is set
if [ -z "$CLIENT_KEY" ]; then
    echo "CLIENT_KEY is not set. Exiting."
    exit 1
fi

# Function to generate keys
generate_keys() {
    umask 077
    wg genkey | tee "$PRIVATE_KEY_FILE" | wg pubkey > "$PUBLIC_KEY_FILE"
}

# Check if the private key exists
if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "Generating new WireGuard keys..."
    generate_keys
else
    echo "Using existing WireGuard keys..."
fi

# Create WireGuard configuration if it doesn't exist
if [ ! -f "$WG_CONFIG" ]; then
    echo "Creating WireGuard configuration..."
    cat <<EOF > "$WG_CONFIG"
[Interface]
PrivateKey = $(cat $PRIVATE_KEY_FILE)
Address = 10.0.0.1/24
ListenPort = $SERVER_PORT

[Peer]
PublicKey = $CLIENT_KEY
AllowedIPs = 10.0.0.2/32
EOF
else
    echo "Using existing WireGuard configuration..."
fi

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

echo "server public key: $PUBLIC_KEY_FILE"

# Keep the container running
tail -f /dev/null

