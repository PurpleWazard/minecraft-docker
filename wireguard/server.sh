#!/bin/bash

CONFIG_DIR="/etc/wireguard"
PRIVATE_KEY_FILE="$CONFIG_DIR/privatekey"
PUBLIC_KEY_FILE="$CONFIG_DIR/publickey"
WG_CONFIG="$CONFIG_DIR/wg0.conf"

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
    if [ -n "$CLIENT_PUBLIC_KEY" ]; then
      echo "[Peer]" >> /etc/wireguard/wg0.conf
      echo "PublicKey = $CLIENT_PUBLIC_KEY" >> /etc/wireguard/wg0.conf
      echo  "AllowedIPs = 10.0.0.2/32" >> /etc/wireguard/wg0.conf
    else
      echo "CLIENT_PUBLIC_KEY environment variable is not set."
      exit 1
    fi
else
    echo "Using existing WireGuard configuration..."
fi




# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Start the WireGuard interface
echo "this is the publickey: $PUBLIC_KEY_FILE "
wg-quick up wg0

# Keep the container running
tail -f /var/log/wireguard/wg.log

