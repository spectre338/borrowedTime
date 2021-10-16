apt update && apt upgrade -y
apt install gpsd gpsd-clients pps-tools ntp -y

sed -i 's/USBAUTO="true"/USBAUTO="false"/g' /etc/default/gpsd
sed -i 's:DEVICES="":DEVICES="/dev/serial0 /dev/pps0":g' /etc/default/gpsd
sed -i 's:GPSD_OPTIONS="":GPSD_OPTIONS="-n":g' /etc/default/gpsd


echo dtoverlay=pps-gpio,gpiopin=18 >> /boot/config.txt
echo pps-gpio >> /etc/modules

sed -i 's/pool 0./# pool 0./g' /etc/ntp.conf
sed -i 's/pool 1./# pool 1./g' /etc/ntp.conf
sed -i 's/pool 2./# pool 2./g' /etc/ntp.conf
sed -i 's/pool 3./# pool 3./g' /etc/ntp.conf

systemctl enable gpsd
systemctl enable ntp


