#!/bin/bash
echo "please run with sudo"
if [ $(ip a | grep eth0 ) ]; then
    NNT="eth0"
else
    NNT="wlan0"
fi
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o "$NNT" -j MASQUERADE
iptables -I FORWARD 1 -s 10.0.0.0/24 -o "$NNT" -j ACCEPT
iptables -I FORWARD 1 -d 10.0.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT
chmod +x qrcode.sh
