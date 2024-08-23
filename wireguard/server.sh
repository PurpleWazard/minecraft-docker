#!/bin/bash

CONFIG_DIR="/etc/wireguard"
PRIVATE_KEY_FILE="$CONFIG_DIR/privatekey"
PUBLIC_KEY_FILE="$CONFIG_DIR/publickey"
WG_CONFIG="$CONFIG_DIR/wg0.conf"

WG_LOG_FILE="/etc/wireguard/wireguard.log"

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
ListenPort = 51820
EOF

echo "[Peer]" >> /etc/wireguard/wg0.conf
echo  "AllowedIPs = 10.0.0.2/32" >> /etc/wireguard/wg0.conf
    if [ -n "$CLIENT_PUBLIC_KEY" ]; then
      echo "CLIENT_PUBLIC_KEY environment variable is not set."
      exit 1
    fi
echo "PublicKey = $CLIENT_PUBLIC_KEY" >> /etc/wireguard/wg0.conf

else
    echo "Using existing WireGuard configuration..."
fi


# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Start the WireGuard interface
echo "this is the publickey: $(cat $PUBLIC_KEY_FILE )"
wg-quick up wg0

if [ ! -f "$WG_LOG_FILE" ]; then
    touch "$WG_LOG_FILE"
    echo "this is the log file" >> "$WG_LOG_FILE"
fi

# Keep the container running
tail -f "$WG_LOG_FILE"

