from arm32v6/alpine

# Install packages
RUN apk update && apk add hostapd iw dhcp vim iptables

# Configure Hostapd (default is UNSECURE)
ADD configs/hostapd/unsecure.conf /etc/hostapd/hostapd.conf

# Configure DHCPD
ADD configs/dhcpd.conf /etc/dhcp/dhcpd.conf
RUN touch /var/lib/dhcp/dhcpd.leases

# Configure networking
ADD configs/wlan0.conf /etc/network/interfaces
ADD configs/iptables.sh /iptables.sh
ADD configs/iptables_off.sh /iptables_off.sh

# Copy and execute init file
ADD configs/start.sh /start.sh
CMD ["/bin/sh", "/start.sh"]