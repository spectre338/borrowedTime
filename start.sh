#!/bin/sh

NOCOLOR='\033[0m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'

sigterm_handler () {
  echo -e "${RED}[*] Caught SIGTERM/SIGINT!${NOCOLOR}"
  pkill hostapd
  cleanup
  exit 0
}
cleanup () {
  echo -e "${YELLOW}[*] Removing iptables rules...${NOCOLOR}"
  sh /iptables_off.sh || echo -e "${RED}[-] Iptables rule error ${NOCOLOR}"
  echo -e "${YELLOW}[*] Restarting wlan0 interface...${NOCOLOR}"
  ifdown wlan0
  ifup wlan0
  echo -e "${GREEN}[+] FIN${NOCOLOR}"
}

trap 'sigterm_handler' TERM INT
echo -e "${YELLOW}[*] Creating iptables rules${NOCOLOR}"
sh /iptables.sh || echo -e "${RED}[-] Problem with iptables rules${NOCOLOR}"

echo -e "${YELLOW}[*] Setting wlan0 ${NOCOLOR}"
ifdown wlan0
ifup wlan0

echo -e "${YELLOW}[+] Configuration complete.. Starting now..${NOCOLOR}"
dhcpd -4 -f -d wlan0 &
hostapd /etc/hostapd/hostapd.conf &
pid=$!
wait $pid

cleanup