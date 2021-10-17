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
# APT update and upgrade
#*******************************************************
apt update && apt upgrade -y
#*******************************************************
# APT Install GPS PPS and NTP & Enable SSH and Serial
#*******************************************************
raspi-config nonint do_ssh
raspi-config nonint do_serial 2
apt install gpsd gpsd-clients pps-tools ntp -y
#*******************************************************
# Alter gpsd
#*******************************************************
sed -i 's/USBAUTO="true"/USBAUTO="false"/g' /etc/default/gpsd
sed -i 's:DEVICES="":DEVICES="/dev/serial0 /dev/pps0":g' /etc/default/gpsd
sed -i 's:GPSD_OPTIONS="":GPSD_OPTIONS="-n":g' /etc/default/gpsd
#*******************************************************
# Enable PPS and config for GPIO 18
#*******************************************************
echo dtoverlay=pps-gpio,gpiopin=18 >> /boot/config.txt
echo pps-gpio >> /etc/modules
#*******************************************************
# JIC
#*******************************************************
telinit q
#*******************************************************
# Enable services
#*******************************************************
systemctl enable gpsd
systemctl enable ntp
#*******************************************************
# Comment out the internet time sources
#*******************************************************
sed -i 's/pool 0./# pool 0./g' /etc/ntp.conf
sed -i 's/pool 1./# pool 1./g' /etc/ntp.conf
sed -i 's/pool 2./# pool 2./g' /etc/ntp.conf
sed -i 's/pool 3./# pool 3./g' /etc/ntp.conf
#*******************************************************
# Confiure /etc/ntp.conf for SHM2 GPS and PPS
#*******************************************************

sudo cat << EOF >> /etc/ntp.conf
#Note that this config works without an internet source.
pool us.pool.ntp.org iburst noselect

broadcast 172.16.0.255

#PPS Kernel driver
server 127.127.22.0 minpoll 4 maxpoll 4 true
fudge 127.127.22.0 flag3 1 refid PPS

# GPS Serial NMEA Driver
server 127.127.28.0 minpoll 4 maxpoll 4 iburst prefer
fudge 127.127.28.0 flag1 1 time1 0.250 refid GPS stratum 1

# Shared Host Memory 2 source
server 127.127.28.2 minpoll 4 maxpoll 4
fudge 127.127.28.2 flag1 1 refid SHM2

# Fix False tickers
tos mindist 0.5
EOF
