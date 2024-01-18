# Made for 18.04
# 2.1.1
apt purge xinetd

# 2.1.2
apt-get remove openbsd-inetd

# 2.2.1.1 - page 138, time synchronization, probably not needed but still look into just in case
#(reccomends time synchronization with vm, so nothin really needed)

# 2.2.1.2 - if timesyncd is used
systemctl enable systemd-timesyncd.service
# change this to sed or somethin idk how to do it, also not sure if this works at all
echo -e "NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org\n\nFallbackNTP=ntp.ubuntu.com 3.ubuntu.pool.ntp.org\n\nRootDistanceMaxSec=1" >> /etc/systemd/timesyncd.conf
systemctl start systemd-timesyncd.service 
timedatectl set-ntp true

# 2.2.1.3 - if chrony is used
# fuck this is manual

# 2.2.1.4 - if ntp is used
# just do this manually

# ADD CONFIRMATION FOR EACH ONE
# 2.2.2
apt purge xserver-xorg*

# 2.2.3
systemctl --now disable avahi-daemon

# 2.2.4
systemctl --now disable cups

# 2.2.5
systemctl --now disable isc-dhcp-server
systemctl --now disable isc-dhcp-server6

# 2.2.6
systemctl --now disable slapd

# 2.2.7
systemctl --now disable nfs-server
systemctl --now disable rpcbind

# 2.2.8
systemctl --now disable bind9

# 2.2.9 - FTP POGU
systemctl --now disable vsftpd

# 2.2.10
systemctl --now disable apache2

# 2.2.11
systemctl --now disable dovecot

# 2.2.12
systemctl --now disable smbd

# 2.2.13
systemctl --now disable squid

# 2.2.14
systemctl --now disable snmpd

# 2.2.15 - FIX BC PROB BROKEN
sudo sed -i "/^#inet_interfaces/ c\inet_interfaces = loopback-only" /etc/postfix/main.cf
systemctl restart postfix

# 2.2.16
systemctl --now disable rsync

# 2.2.17
systemctl --now disable nis

# 2.3.1
apt purge nis

# 2.3.2
apt remove rsh-client

# 2.3.3
apt remove talk

# 2.3.4
apt purge telnet

# 2.3.5
apt purge ldap-utils