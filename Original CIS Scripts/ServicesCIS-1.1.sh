# This is made for Ubuntu 18.04, so things might not work for other versions
BLUE="\e[94m"
RED="\e[91m"
YELLOW="\e[93m"
GREEN="\e[92m"
NC="\e[0m"

# Remove Malware
services=(avahi-daemon cups isc-dhcp-server isc-dhcp-server6 slapd nfs-server rpcbind bind9 vsftpd apache2 dovecot smbd squid snmpd rsync nis)
printf "$BLUE	Disable Services\n"
printf "    --------------------$NC\n"
for prog in ${services[@]}
do
	printf "$YELLOW	Disable $prog? $NC"
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		printf "$RED Disabling $prog $NC"
		systemctl --now disable $prog
	fi
done

# Remove and Purge are seperate for the sake of the coding
# REMOVE SERVICES
rservices=(openbsd-inetd rsh-client talk) # openbsd is apt-get rather than apt, so all remove have been changed to fit
printf "$BLUE	Remove Services\n"
printf "    --------------------$NC\n"
printf "$GREEN List all removable services?$NC "
if [[ $REPLY =~ ^[Yy]$ ]]
then
	for serv in ${rservices[@]}
	do
		printf "$YELLOW	\t$serv $NC\n"
	fi
done
printf "$BLUE Mass Remove? $NC"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	for serv in ${rservices[@]}
	do
		printf "$RED Removing $serv $NC\n"
		apt-get remove $serv
	done
else
	for serv in ${rservices[@]}
	do
		printf "$YELLOW	Remove $serv? $NC"
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			printf "$RED Removing $serv $NC\n"
			apt-get remove $serv
		fi
	done
fi

# PURGE SERVICES
pservices=(xinetd xserver-xorg* nis telnet ldap-utils)
printf "$BLUE	Purge Services\n"
printf "    --------------------$NC\n"
printf "$GREEN List all purgeable services?$NC "
if [[ $REPLY =~ ^[Yy]$ ]]
then
	for serv in ${pservices[@]}
	do
		printf "$YELLOW	\t$serv $NC\n"
	fi
done
printf "$BLUE Mass Purge? $NC"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	for serv in ${pservices[@]}
	do
		printf "$RED Purging $serv $NC\n"
		apt purge $serv
	done
else
	for serv in ${rservices[@]}
	do
		printf "$YELLOW	Remove $serv? $NC"
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			printf "$RED Removing $serv $NC\n"
			apt purge $serv
		fi
	done
fi

# misc services
# THIS SHOULD PROB BE TESTED AND FIXED, I DON"T THINK I USED SED CORRECTLY
printf "$BLUE	2.2.15 Ensure mail transfer agent is configured for local-only mode$NC\n"
sudo sed -i "/^#inet_interfaces/ c\inet_interfaces = loopback-only" /etc/postfix/main.cf
systemctl restart postfix
printf "$GREEN DONE!$NC"