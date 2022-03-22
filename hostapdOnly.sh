#!/bin/bash
#########################################################
# Created by W7SVT Oct 2021 #############################
#########################################################
#########################################################
#  __      ___________  _____________   _______________ #
# /  \    /  \______  \/   _____/\   \ /   /\__    ___/ #
# \   \/\/   /   /    /\_____  \  \   Y   /   |    |    #
#  \        /   /    / /        \  \     /    |    |    #
#   \__/\  /   /____/ /_______  /   \___/     |____|    #
#        \/                   \/                        #
#########################################################

#*******************************************************
echo "APT install hostapd and dnsmasq"
#*******************************************************
sudo apt-get install -y hostapd dnsmasq
sudo systemctl stop dnsmasq
#*******************************************************
echo "Move hostapd config to destination"
#*******************************************************
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
#*******************************************************
echo "Point hostapd to config location"
#*******************************************************
sudo sed -i 's*#DAEMON_CONF=""*DAEMON_CONF="/etc/hostapd/hostapd.conf"*g'  /etc/default/hostapd 
#*******************************************************
echo "Unmask and enable hostapd sevice"
#*******************************************************
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
#*******************************************************
echo "Setup dnsmasq for IP ranges and config"
#*******************************************************
echo "
#borrowedTime Hotspot config - Routed
interface=wlan0
bind-dynamic
domain-needed
bogus-priv
dhcp-range=172.16.0.150,172.16.0.200,255.255.255.0,12h
dhcp-authoritative
log-queries

" | sudo tee -a /etc/dnsmasq.conf
#*******************************************************
echo "Setup DHCP leases"
#*******************************************************
echo "
#borrowedTime Hotspot config - Routed
nohook wpa_supplicant
interface wlan0
static ip_address=172.16.0.1/24
static routers=172.16.0.1
static domain_name_servers=8.8.8.8
" | sudo tee -a /etc/dhcpcd.conf
#*******************************************************
echo "Uncomment ipv4 forwarding"
#*******************************************************
sudo sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf 
#*******************************************************
echo "Create iptables script"
#*******************************************************
cat >iptables-hs <<EOF
#!/bin/bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
EOF

sudo mv iptables-hs /etc/iptables-hs

sudo chmod +x /etc/iptables-hs
#*******************************************************
echo "Create Hotspot iptable service"
#*******************************************************
echo "
[Unit]
Description=Activate IPtables for Hotspot
After=network-pre.target
Before=network-online.target

[Service]
Type=simple
ExecStart=/etc/iptables-hs

[Install]
WantedBy=multi-user.target
" | sudo tee -a  /etc/systemd/system/hs-iptables.service

sudo systemctl enable hs-iptables
#*******************************************************
echo "Update hosts to send client NTP without changing any settings"
#*******************************************************
echo "
172.16.0.1              0.debian.pool.ntp.org
172.16.0.1              1.debian.pool.ntp.org
172.16.0.1              2.debian.pool.ntp.org
172.16.0.1              3.debian.pool.ntp.org
" | sudo tee -a  /etc/hosts
