# borrowedTime

To be fare I have no intention of returning the time. However stolenTime sounds a bit klepto

### Assumptions
Fresh install of RaspberryPi OS
Love of Ham Radio

### CLI Enable serial port and SSH:
sudo raspi-config nonint do_ssh 0
sudo raspi-config nonint do_serial 2

### Install Step 1
```
cd ~
git clone https://github.com/W7SVT/borrowedTime.git
cd ~/borrowedTime
sudo sh GPSD_NTP_Setup.sh
```
### Install Step 2
```
sudo reboot
```

### Install Step 3
```
cd ~
git clone https://github.com/W7SVT/borrowedTime.git
cd ~/borrowedTime
sh hostapdOnly.sh
```

#### Note: Once you have installed everything a reboot is nessasary

