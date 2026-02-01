#!/bin/bash

IP=$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -vE '^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|127\.)' | head -n 1)

TEXT=$(tput setaf 6)" ========================================
         GRE Tunnel Setup Wizard
              By Wreck3dMind
 ========================================"$(tput setaf 5)

printf "$TEXT\n\n"

echo 'Select server type:'
echo '1 - Relay'
echo '2 - Endpoint'
read -p 'Enter 1 or 2: ' TYPE

read -p 'Enter the destination IP address: ' REMOTE_IP

if [[ "$TYPE" == "1" ]]; then
    read -p 'Enter the port: ' PORT
fi

echo $(tput sgr0)

sudo ip link add name gre1 type gre local $IP remote $REMOTE_IP
sudo ip link set gre1 up

if [[ "$TYPE" == "1" ]]; then
    sudo ip addr add 10.1.1.2/8 dev gre1

    sysctl net.ipv4.ip_forward=1

    sudo iptables -t nat -A PREROUTING -p tcp --dport $PORT -j DNAT --to-destination 10.1.1.1:$PORT
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE

    sudo iptables -A INPUT --proto icmp -j DROP

else
    sudo ip addr add 10.1.1.1/8 dev gre1
fi