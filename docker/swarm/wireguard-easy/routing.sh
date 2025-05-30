#!/bin/bash
# NOTE: This must be run inside de container

# Clear previous WireGuard-related rules
iptables -D FORWARD -i docker_gwbridge -o ens18 -j ACCEPT 2>/dev/null
iptables -D FORWARD -i ens18 -o docker_gwbridge -j ACCEPT 2>/dev/null
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o ens18 -j MASQUERADE 2>/dev/null

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >/etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

# Add rules to connect Docker networks to host network
iptables -A FORWARD -i docker_gwbridge -o ens18 -j ACCEPT
iptables -A FORWARD -i ens18 -o docker_gwbridge -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ens18 -j MASQUERADE

# Save the rules to make them persistent
if command -v netfilter-persistent &>/dev/null; then
	netfilter-persistent save
elif command -v iptables-save &>/dev/null; then
	iptables-save >/etc/iptables/rules.v4
else
	echo "Could not find a method to save iptables rules."
	echo "Please install iptables-persistent or netfilter-persistent."
	echo "Rules will be lost on reboot."
fi

echo "WireGuard routing has been set up successfully."
