#/bin/sh
set -exu

# Configure network for VM
uci del network.lan || true
uci set network.wan=interface
uci set network.wan.ifname='eth0'
uci set network.wan.proto='dhcp'
uci commit network && /etc/init.d/network restart

# Configure firewall for VM
uci set firewall.ssh_wan=rule
uci set firewall.ssh_wan.name='Allow-SSH-from-WAN'
uci set firewall.ssh_wan.src='wan'
uci set firewall.ssh_wan.dest_port='22'
uci set firewall.ssh_wan.proto='tcp'
uci set firewall.ssh_wan.target='ACCEPT'
uci commit firewall && /etc/init.d/firewall reload
