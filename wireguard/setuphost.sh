#!/bin/bash
echo "please run with sudo"
if [ $(ip a | grep eth0 ) ]; then
    NNT="eth0"
else
    NNT="wlan0"
fi


# my vpn network 10.0.0.0/24 subnet
#
# current host network 192.168.1.0/24
sysctl -w net.ipv4.ip_forward=1


sudo iptables -A FORWARD -i wg0 -o "$NNT" -s 10.0.0.0/24 -d 192.168.1.0/24 -j ACCEPT

sudo iptables -A FORWARD -i "$NNT" -o wg0 -s 192.168.1.0/24 -d 10.0.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -d 192.168.1.0/24 -o "$NNT" -j MASQUERADE


chmod +x qrcode.sh
