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

sudo sysctl net.ipv4.ip_forward && sudo sysctl net.ipv4.ip_forward=1
sudo sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf 

sudo cat << EOF >> /etc/dhcpcd.conf

# Setup for portal
denyinterfaces wlan0
EOF

apt-get install -y \
	uidmap \
	libffi-dev \
	libssl-dev \
	python3 \
	python3-pip

curl -sSL https://get.docker.com | sh 
dockerd-rootless-setuptool.sh install

sudo usermod -aG docker ${USER}

sudo pip3 install docker-compose

sudo systemctl enable docker
