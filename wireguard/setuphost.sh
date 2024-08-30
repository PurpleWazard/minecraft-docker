#!/bin/bash

echo "please run with sudo"

sysctl -w net.ipv4.ip_forward=1

if [ $(ip a | grep eth0 ) ]; then
    iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
else
    iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlan0 -j MASQUERADE
fi

chmod +x qrcode.sh

