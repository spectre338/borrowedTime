sudo apt-get install -y hostapd dnsmasq

sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

sudo cp hostapd.conf /etc/hostapd/hostapd.conf

sudo sed -i 's*#DAEMON_CONF=""*DAEMON_CONF="/etc/hostapd/hostapd.conf"*g'  /etc/default/hostapd 


sudo systemctl unmask hostapd
sudo systemctl enable hostapd

echo "
#borrowedTime Hotspot config - Routed
interface=wlan0
bind-dynamic
domain-needed
bogus-priv
dhcp-range=172.16.0.150,172.16.0.200,255.255.255.0,12h
" | sudo tee -a /etc/dnsmasq.conf

echo "
#borrowedTime Hotspot config - Routed
nohook wpa_supplicant
interface wlan0
static ip_address=172.16.0.1/24
static routers=172.16.0.1
static domain_name_servers=8.8.8.8
" | sudo tee -a /etc/dhcpcd.conf

sudo sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf 

echo "
#!/bin/bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
" | sudo tee -a  /etc/iptables-hs

sudo chmod +x /etc/iptables-hs

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

echo "
172.16.0.1		0.debian.pool.ntp.org
172.16.0.1              2.debian.pool.ntp.org
172.16.0.1              2.debian.pool.ntp.org
172.16.0.1              3.debian.pool.ntp.org
" | sudo tee -a  /etc/hosts
