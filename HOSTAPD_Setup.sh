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
echo "APT update and upgrade"
#*******************************************************
#apt update 

sysctl net.ipv4.ip_forward
sysctl net.ipv4.ip_forward=1
sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf 

sudo cat << EOF >> /etc/dhcpcd.conf

# Setup for portal
denyinterfaces wlan0
EOF

curl -sSL https://get.docker.com | sh 



sudo usermod -aG docker ${USER}
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip

sudo pip3 install docker-compose

sudo systemctl enable docker
