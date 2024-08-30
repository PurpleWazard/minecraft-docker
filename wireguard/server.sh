#!/bin/bash
CONFIG_DIR="/etc/wireguard"
WG_CONFIG="$CONFIG_DIR/wg0.conf"
PUB_FILE="$CONFIG_DIR/public"
PRI_FILE="$CONFIG_DIR/private"


CLIENT_KEY="$CLIENT_KEY"
CLIENT_KEY_FILE="$CONFIG_DIR/client_pub"
CLIENT_PRI_FILE="$CONFIG_DIR/client_pri"
CLIENT_CONFIG="$CONFIG_DIR/client.conf"

echo "$KEY_PRIVATE and $KEY_PUBLIC"

# Check if the key files exist
if [ ! -f "$PUB_FILE" ] || [ ! -f "$PRI_FILE" ]; then

    # Generate new keys if private key is not provided
    if [ -z "$KEY_PRIVATE" ]; then
        umask 600 
        KEY_PRIVATE=$(wg genkey)
        KEY_PUBLIC=$(echo "$KEY_PRIVATE" | wg pubkey)
    else
        # Use provided private key to generate public key
        KEY_PUBLIC=$(echo "$KEY_PRIVATE" | wg pubkey)
    fi

    # Save keys to files
    echo "$KEY_PRIVATE" > "$PRI_FILE"
    echo "$KEY_PUBLIC" > "$PUB_FILE"
fi

if [ -z "$KEY_PUBLIC" ] && [ -z "$KEY_PRIVATE" ]; then
    KEY_PUBLIC=$(cat "$PUB_FILE")
    KEY_PRIVATE=$(cat "$PRI_FILE")
fi



# Check if provided keys differ from stored keys
if [ "$KEY_PRIVATE" != "$(cat "$PRI_FILE")" ]; then
    echo "$KEY_PRIVATE" > "$PRI_FILE"
fi

if [ "$KEY_PUBLIC" != "$(cat "$PUB_FILE")" ]; then
    echo "$KEY_PUBLIC" > "$PUB_FILE"
fi


echo "Private key: $KEY_PRIVATE and file: $(cat $PRI_FILE)"
echo "public key: $KEY_PUBLIC and file: $(cat $PUB_FILE)"











echo "$CLIENT_PRI_KEY and $CLIENT_KEY"

# Check if the key files exist
if [ ! -f "$CLIENT_KEY_FILE" ] || [ ! -f "$CLIENT_PRI_FILE" ]; then

    # Generate new keys if private key is not provided
    if [ -z "$CLIENT_PRI_KEY" ]; then
        umask 600 
        CLIENT_PRI_KEY=$(wg genkey)
        CLIENT_KEY=$(echo "$CLIENT_PRI_KEY" | wg pubkey)
    else
        # Use provided private key to generate public key
        CLIENT_KEY=$(echo "$CLIENT_PRI_KEY" | wg pubkey)
    fi

    # Save keys to files
    echo "$CLIENT_PRI_KEY" > "$CLIENT_PRI_FILE"
    echo "$CLIENT_KEY" > "$CLIENT_KEY_FILE"
fi

if [ -z "$CLIENT_KEY" ] && [ -z "$CLIENT_PRI_KEY" ]; then
    CLIENT_KEY=$(cat "$CLIENT_KEY_FILE")
    CLIENT_PRI_KEY=$(cat "$CLIENT_PRI_FILE")
fi



# Check if provided keys differ from stored keys
if [ "$CLIENT_PRI_KEY" != "$(cat "$CLIENT_PRI_FILE")" ]; then
    echo "$CLIENT_PRI_KEY" > "$CLIENT_PRI_FILE"
fi

if [ "$CLIENT_KEY" != "$(cat "$CLIENT_KEY_FILE")" ]; then
    echo "$CLIENT_KEY" > "$CLIENT_KEY_FILE"
fi


if [ -z "$CLIENT_KEY" ] || [ -z "$CONFIG_PRI_KEY"]; then

    if [ ! -f "$CLIENT_PRI_FILE" ] && [ -z "$CLIENT_PRI_KEY" ]; then

        CLIENT_PRI_KEY=$(wg genkey)
        echo $CLIENT_PRI_KEY > $CLIENT_PRI_FILE

    elif [ ! -f "$CLIENT_KEY_FILE" ] && [ -z "$CLIENT_KEY" ]; then

        echo $CLIENT_KEY > $CLIENT_KEY_FILE
        CLIENT_KEY=$(echo $CLIENT_PRI_KEY | wg pubkey)

    fi

else 

    echo "$(cat "$CLIENT_PRI_FILE")"

fi


if [ "$CLIENT_KEY" != $(cat "$CLIENT_KEY_FILE") ]; then
    echo $CLIENT_KEY > $CLIENT_KEY_FILE
elif [ "$CLIENT_PRI_KEY" != $(cat "$CLIENT_PRI_FILE") ]; then
    echo $CLIENT_PRI_KEY > $CLIENT_PRI_FILE
fi


#server
cat <<EOF > "$WG_CONFIG"
[Interface]
PrivateKey = $KEY_PRIVATE
Address = 10.0.0.1/24
ListenPort = $SERVER_PORT
$SERVER_DNS

[Peer]
PublicKey = $CLIENT_KEY
AllowedIPs = 10.0.0.2/32
EOF



# client
cat <<EOF > "$CLIENT_CONFIG"
[Interface]
PrivateKey = $CLIENT_PRI_KEY
Address = 10.0.0.2/24
$CLIENT_DNS


[Peer]
PublicKey = $KEY_PUBLIC
Endpoint = $ENDPOINT:$SERVER_PORT
AllowedIPs = $ALLOWEDIPS
$KEEPALIVE
EOF



# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Set up NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Ensure forwarding rules are in place (if needed)
iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT

ip link delete wg0 || true
# Start the WireGuard interface
wg-quick up wg0

sleep infinitely

# export TERM=xterm-256color
#
#
# tput clear
#
# while true; do
#
#     tput home
#     tput clear
#     echo ""
#     echo  "Private key: $KEY_PRIVATE and file: $(cat $PRI_FILE)"
#     echo  "public key: $KEY_PUBLIC and file: $(cat $PUB_FILE)"
#     echo  "client key: $CLIENT_KEY"
#     tput cup 4 0
#     echo""
#     echo "$(wg show)"
#     sleep 1
# done

