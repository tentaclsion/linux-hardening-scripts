#!/bin/bash
# cron/artists/ Logo
printf " ██████╗██████╗  ██████╗ ███╗   ██╗ \e[91m   ██╗\e[0m █████╗ ██████╗ ████████╗██╗███████╗████████╗███████╗   \e[91m ██╗\e[0m \n"
printf "██╔════╝██╔══██╗██╔═══██╗████╗  ██║ \e[91m  ██╔╝\e[0m██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝╚══██╔══╝██╔════╝  \e[91m ██╔╝\e[0m \n"
printf "██║     ██████╔╝██║   ██║██╔██╗ ██║ \e[91m ██╔╝\e[0m ███████║██████╔╝   ██║   ██║███████╗   ██║   ███████╗ \e[91m ██╔╝ \e[0m \n"
printf "██║     ██╔══██╗██║   ██║██║╚██╗██║\e[91m ██╔╝\e[0m  ██╔══██║██╔══██╗   ██║   ██║╚════██║   ██║   ╚════██║\e[91m ██╔╝ \e[0m  \n"
printf "╚██████╗██║  ██║╚██████╔╝██║ ╚████║\e[91m██╔╝ \e[0m  ██║  ██║██║  ██║   ██║   ██║███████║   ██║   ███████║\e[91m██╔╝  \e[0m  \n"
printf " ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝\e[91m╚═╝ \e[0m   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚══════╝   ╚═╝   ╚══════╝\e[91m╚═╝ \e[0m  \n"
sleep 0.65
printf "\n<*> Ubuntu Security Scripts Started\n"
username=$(whoami)

#Determine linux version
os_version=$(lsb_release -a | awk '{print $2}'| tr -d '\n' | cut -c 4- | cut -c -11)

function pause_script
{
	read -s -n 1 -p "Press any key to continue..."
	printf "\n"
}
# !!! CHANGE /cis-hardening/ruleset-params.conf FOR EACH ONE (possibly manually) https://ubuntu.com/security/certifications/docs/cis-ruleset-params
function cis_ubu20 # not sure if i put sudo in the right place
{
	sudo chmod a+x /CIS/CIS20/cis-hardening/Canonical_Ubuntu_20.04_CIS-harden.sh
	gnome-terminal -e "bash -c \'sudo ./CIS/CIS18/cis-hardening/Canonical_Ubuntu_18.04_CIS-harden.sh; exec bash\'"
}
function cis_ubu18 
{
	sudo chmod a+x /CIS/CIS18/cis-hardening/Canonical_Ubuntu_18.04_CIS-harden.sh
	gnome-terminal -e "bash -c \'sudo ./CIS/CIS18/cis-hardening/Canonical_Ubuntu_18.04_CIS-harden.sh; exec bash\'"
}
function cis_ubu16
{
	echo bruh
}
function decide 
{
	printf "Select what you would like to do:\n\t[1] Updates\n\t[2] Audit and Mischellaneous\n\t[3] User Management\n\t[4] File and Program Management\n\t[5] Anti-virus\n\t[6] Networking\n"
	read -p "" -n 1 -r
	echo
	if [[ $REPLY =~ ^[1]$ ]]
	then
		clear
		printf "<*> Proceeding with updates...\n"
		sleep 0.65
		printf "\tChanging update policies first...\n"
		
		printf "\t\t<*> Updating...\n"
		sudo add-apt-repository -y ppa:libreoffice/ppa
		sudo cp -TRv ConfigFiles/sources.list /etc/apt/sources.list
		printf "<*> Remember to change update policies in the GUI as well..."
		sudo apt-get update 
		sudo apt-get upgrade
		sudo apt-get dist-upgrade
		sudo update-manager -d
		sudo apt-get autoremove 
		sudo apt-get autoclean
		sudo killall firefox
		sudo apt-get --purge --reinstall install firefox -y
		sudo apt-get install hardinfo 
		sudo apt-get install chkrootkit 
		sudo apt-get install iptables 
		sudo apt-get install portsentry 
		sudo apt-get install lynis 
		sudo apt-get install clamav 
		sudo apt-get install rkhunter 
		sudo apt-get install apparmor apparmor-profiles
		sudo apt-get install gconf2
		sudo apt-get install -y --reinstall coreutils
		sudo rkhunter --propupd
		sudo systemctl stop clamav-freshclam
		sudo freshclam #if this doesn't work use ps aux | grep clam and kill the process being ran by clamav then rerun the same command
		printf "<*> Remember to change firefox as default browser by going into system settings, details, default applications..."
		sudo apt-get install -y unattended-upgrades
		sudo cp -TRv ConfigFiles/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
		sudo chmod 644 /etc/apt/apt.conf.d/50unattended-upgrades
		sudo sed -i -e 's/APT::Periodic::Update-Package-Lists.*\+/APT::Periodic::Update-Package-Lists "1";/' /etc/apt/apt.conf.d/10periodic
		sudo sed -i -e 's/APT::Periodic::Download-Upgradeable-Packages.*\+/APT::Periodic::Download-Upgradeable-Packages "0";/' /etc/apt/apt.conf.d/10periodic
		sudo cp -TRv ConfigFiles/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
		sudo chmod 644 /etc/apt/apt.conf.d/20auto-upgrades
		sudo dpkg-reconfigure -plow unattended-upgrades #Press Yes
		#after this do the config file for unattended-upgrades

		decide
	fi
	if [[ $REPLY =~ ^[6]$ ]]
	then
		clear
		printf "<*> Proceeding with networking...\n"
		sleep 0.65
		printf "<#> Installing general firewall..."
		sudo apt-get install ufw -y
		sudo ufw allow ssh
		sudo ufw allow http
		sudo ufw deny 23
		sudo ufw deny 2049
		sudo ufw deny 515
		#sudo ufw deny 111
		sudo ufw default deny
		sudo ufw enable
		#Clear out and default iptables
		sudo iptables -t nat -F
		sudo iptables -t mangle -F
		sudo iptables -t nat -X
		sudo iptables -t mangle -X
		sudo iptables -F # this breaks the image since it flushes the network, potentially have to restart after this?
		sudo iptables -X # this has to be done right after previous command
		sudo iptables -P INPUT DROP
		sudo iptables -P FORWARD DROP
		sudo iptables -P OUTPUT ACCEPT
		sudo ip6tables -t nat -F
		sudo ip6tables -t mangle -F
		sudo ip6tables -t nat -X
		sudo ip6tables -t mangle -X
		sudo ip6tables -F
		sudo ip6tables -X
		sudo ip6tables -P INPUT DROP
		sudo ip6tables -P FORWARD DROP
		sudo ip6tables -P OUTPUT DROP
		#Blocks bogons going into the computer
		printf "<*> Enter the primary internet interface:\n"
		read interface
		sudo iptables -A INPUT -s 127.0.0.0/8 -i $interface -j DROP
		sudo iptables -A INPUT -s 0.0.0.0/8 -j DROP
		sudo iptables -A INPUT -s 100.64.0.0/10 -j DROP
		sudo iptables -A INPUT -s 169.254.0.0/16 -j DROP
		sudo iptables -A INPUT -s 192.0.0.0/24 -j DROP
		sudo iptables -A INPUT -s 192.0.2.0/24 -j DROP
		sudo iptables -A INPUT -s 198.18.0.0/15 -j DROP
		sudo iptables -A INPUT -s 198.51.100.0/24 -j DROP
		sudo iptables -A INPUT -s 203.0.113.0/24 -j DROP
		sudo iptables -A INPUT -s 224.0.0.0/3 -j DROP
		#Blocks bogons from leaving the computer
		sudo iptables -A OUTPUT -d 127.0.0.0/8 -o $interface -j DROP
		sudo iptables -A OUTPUT -d 0.0.0.0/8 -j DROP
		sudo iptables -A OUTPUT -d 100.64.0.0/10 -j DROP
		sudo iptables -A OUTPUT -d 169.254.0.0/16 -j DROP
		sudo iptables -A OUTPUT -d 192.0.0.0/24 -j DROP
		sudo iptables -A OUTPUT -d 192.0.2.0/24 -j DROP
		sudo iptables -A OUTPUT -d 198.18.0.0/15 -j DROP
		sudo iptables -A OUTPUT -d 198.51.100.0/24 -j DROP
		sudo iptables -A OUTPUT -d 203.0.113.0/24 -j DROP
		sudo iptables -A OUTPUT -d 224.0.0.0/3 -j DROP
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP         #Block Telnet
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
		sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #Block NFS
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #Block X-Windows
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #Block X-Windows font server
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
		sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #Block printer port
		sudo iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
		sudo iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #Block Sun rpc/NFS
		sudo iptables -A INPUT -p all -s localhost  -i eth0 -j DROP            #Deny outside packets from internet which claim to be from your loopback interface.
		#sudo touch /etc/iptables/rules.v4
		#sudo touch /etc/iptables/rules.v6
		#sudo iptables-save -f /etc/iptables/rules.v4
		#sudo ip6tables-save -f /etc/iptables/rules.v6
		sudo portsentry -tcp #This daemon will watch unused ports for activity and depending on how it is configured take action upon excessive access to watched ports
		sudo portsentry -udp
		sudo portsentry -stcp
		sudo portsentry -atcp
		sudo portsentry -sudp
		sudo portsentry -audp
		sudo apt-get --yes purge nfs-kernel-server nfs-common portmap rpcbind autofs #Network-File-Sharing default for linux, best to delete unless being used
		#Skim through open ports to notice anything suspicious
		printf "<*> Running lsof -i -n -P and saving it under lsof_ports.txt\n"
		sudo lsof -i -n -P > lsof_ports.txt
		printf "<*> Running netstat -tulpn and saving it under netstat_ports.txt\n"
		sudo netstat -tulpn > netstat_ports.txt
		printf "<*> Remember to restart your computer in order to download stuff"
		decide
	fi
	if [[ $REPLY =~ ^[3]$ ]]
	then
		clear
		printf "<*> Proceeding with user managment...\n"
		sleep 0.65

		printf "<*> Need to add any users: <Y|N>\n"
		read -p "" -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			printf "<*> Enter list of users to add: \n"
			read -a addUsers
			for user in "${addUsers[@]}"
			do
			sudo useradd $user
			echo -e "fr1gusS1gnum!\nfr1gusS1gnum!\n" | sudo passwd $user
			done
		fi
		declare -a users_system
		declare -a hidden_users
		hiddenUsers=($(cut -d: -f1,3 /etc/passwd | egrep ':[0]{1}$' | cut -d: -f1))
		usersSystem=($(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1))
		
		printf "<*> Make sure to include yourself in this list\n<*> Enter the authorized admin users: \n"
		read -a authAdmUsers #make sure that you're included in this list
		printf "\n<*> Enter authorized standard users: \n"
		read -a authStdUsers
		for userInSystem in "${usersSystem[@]}"
		do
			if [[ ! "${authAdmUsers[*]}" =~ "${userInSystem}" ]] && [[ ! "${authStdUsers[*]}" =~ "${userInSystem}" ]]
			then
			printf "<*> Deleting user: ${userInSystem} from system..."
			sudo userdel -r $userInSystem
			else
			if [[ "${authAdmUsers[*]}" =~ "${userInSystem}" ]] && ! getent group sudo | grep -q '\b$userInSystem\b'
			then
				sudo usermod -aG sudo $userInSystem
			elif [[ ! "${authAdmUsers[*]}" =~ "${userInSystem}" ]] && getent group sudo | grep -q '\b$userInSystem\b'
			then
				sudo gpasswd -d $userInSystem sudo
			fi
			fi
		done

		#Fix this and add more password policies that are more stern: use stig policies for it to establish better passwords etc
		printf "<*> Establishing password policies...\n"
		sudo apt-get install -y libpam-pwquality #alternative would be to use libpam-cracklib but stig uses pwquality, if doesnt give point could be worth a shot to try cracklib
		#sed -i -e 's/PASS_MAX_DAYS\t[[:digit:]]\+/PASS_MAX_DAYS\t60/' /etc/login.defs
		#sed -i -e 's/PASS_MIN_DAYS\t[[:digit:]]\+/PASS_MIN_DAYS\t10/' /etc/login.defs
		#sed -i -e 's/PASS_WARN_AGE\t[[:digit:]]\+/PASS_WARN_AGE\t7/' /etc/login.defs				
		sudo cp -TRv ConfigFiles/login.defs /etc/login.defs
		sudo chmod 644 /etc/login.defs
		sudo cp -TRv ConfigFiles/pwquality.conf /etc/security/pwquality.conf
		sudo chmod 644 /etc/security/pwquality.conf
		decide
	fi
	if [[ $REPLY =~ ^[4]$ ]]
	then
		clear
		printf "<*> Proceeding with file and program management...\n"
		sleep 0.65
		declare -a file_extensions
		while read line; do
			file_extensions+=($line)
		done < lists/file_extensions.txt
		for extension in ${file_extensions[@]}
		do
			touch found_files.list
			find / -name '*.$extension' -print > found_files.list
		done
		printf "<#> Delete files in found_files.list before continuing\n"
		pause_script

		printf "<*> Uninstalling all games and malware...\n"
		declare -a unwanted_programs
		while read line; do
			unwanted_programs+=($line)
		done < lists/unwanted_programs.txt
		for prog in ${unwanted_programs[@]}
		do
			sudo apt-get -y purge $prog
			sudo apt-get -y autoremove --purge $prog
			sudo snap remove $prog
			sudo flatpak uninstall $prog
			
		done
		
		# services - i just copied this from the old script, have fun cleaning it up
		printf "<*> Install/Uninstall MySQL <I|U|N>: "
		read -p "" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Ii]$ ]]
		then
			printf "<*> Installing MySQL...\n"
			sudo apt-get -y install mysql-server
			printf "<*> Disabling remote access...\n"
			sudo sed -i "/bind-address/ c\bind-address = 127.0.0.1" /etc/mysql/my.cnf
			printf "<*> Restarting MySQL...\n"
			sudo service mysql restart
			sudo ufw allow mysql
		elif [[ $REPLY =~ ^[Uu]$ ]]
		then
			sudo apt-get -y purge mysql
		fi

		# OpenSSH
		printf "<*> Install/Uninstall OpenSSH <I|U|N>: "
		read -p "" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Ii]$ ]]
		then
			printf "<*> Installing OpenSSH...\n"
			sudo apt-get -y install openssh-server
			printf "<*> Configuring SSh security...\n"
			#/etc/ssh/ssh_config
			#ssh config-should check if openssh is installed to automatically set up Configuring
			#switch port 22;protocol ssh 2;permit root login no; passwordAuthentication no;permitEmptyPasswords no;clientAliveInterval 360(seconds);clientAliveCountMax 0; AllowTcpForwarding no; X11Forwarding no; restrict certain ip addresses
			#set up firewall for the chosen ssh port
			#***THINK OF USING FAIL2BAN***
			#sudo sed -i "/^#PermitRootLogin/ c\PermitRootLogin no" /etc/ssh/sshd_config
			#sudo sed -i "/^#Port/ c\Port 22" /etc/ssh/sshd_config
			#sudo sed -i "/^#PasswordAuthentication/ c\PasswordAuthentication no" /etc/ssh/sshd_config
			#sudo sed -i "/^#PermitEmptyPasswords/ c\PermitEmptyPasswords no" /etc/ssh/sshd_config
			#sudo sed -i "/^#ClientAliveInterval/ c\ClientAliveInterval 360" /etc/ssh/sshd_config
			#sudo sed -i "/^#ClientAliveCountMax/ c\ClientAliveCountMax 0" /etc/ssh/sshd_config
			#sudo sed -i "/^#AllowTcpForwarding/ c\AllowTcpForwarding no" /etc/ssh/sshd_config
			#sudo sed -i "/^#X11Forwarding/ c\X11Forwarding no" /etc/ssh/sshd_config
			#sudo echo -e "Protocol 2" | sudo tee --append /etc/ssh/sshd_config
			#printf "<*> Restarting Server...\n"
			sudo chattr -i /etc/ssh/sshd_config
			sudo chmod 777 /etc/ssh/sshd_config
			sudo cp -TRv ConfigFiles/sshd_config /etc/ssh/sshd_config
			sudo service ssh restart
			sudo chmod 770 /etc/ssh/sshd_config
			sudo ufw allow ssh
		elif [[ $REPLY =~ ^[Uu]$ ]]
		then
			sudo apt-get -y purge openssh-server
		fi

		# VSFTPD
		printf "<*> Install/Uninstall VSFTPD <I|U|N>:"
		read -p "" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Ii]$ ]]
		then
			printf "<*> Installing VSFTPD...\n"
			sudo apt-get -y install vsftpd
			printf "<*> Disabling ANONYMOUS uploads...\n"
			sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
			sudo sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
			printf "<*> Configuring FTP directories...\n"
			sudo sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
			printf "<*> Restarting VSFTPD...\n"
			sudo service vsftpd restart
		elif [[ $REPLY =~ ^[Uu]$ ]]
		then
			sudo apt-get -y purge vsftpd
		fi

		# Samba
		printf "<*> Install/Uninstall Samba <I|U|N>: "
		read -p "" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Ii]$ ]]
		then
			printf "<*> Installing Samba...\n"
			sudo apt-get -y install samba
			sudo chattr -i /etc/samba/smb.conf
			sudo chmod 777 /etc/samba/smb.conf
			sudo cp -TRv ConfigFiles/smb.conf /etc/samba/smb.conf
			sudo service smbd restart
			sudo chmod 770 /etc/samba/smb.conf
			sudo ufw allow samba
		elif [[ $REPLY =~ ^[Uu]$ ]]
		then
			sudo apt-get -y purge samba
		fi

		# DO NOT DO THIS, i think snap is still a vital package manager used in ubuntu
		# printf "<*> Uninstalling other package managers and their daemons..."
		# sudo rm -rf /var/cache/snapd/
		# sudo apt autoremove --purge snapd gnome-software-plugin-snap
		# rm -rf ~/snap

		decide
	fi
	if [[ $REPLY =~ ^[5]$ ]]
	then
		clear
		printf "<*> Proceeding with anti virus...\n"
		sleep 0.65
		
		sudo clamscan -r -i --stdout --exclude-dir="^/sys" /
		pause_script

		sudo rkhunter --update
		sudo rkhunter --check #may result in false positive for portsentry
		pause_script

		lynis -c
		pause_script

		decide
	fi	
	if [[ $REPLY =~ ^[2]$ ]]
	then
		clear
		#printf "<*> Proceeding with CIS policies...\n"
		sleep 0.65

		# Firefox CIS
		#printf "<*> Copying Firefox CIS compliant settings...\n"
		#cp files/local-settings.js /usr/lib/firefox/defaults/pref/local-settings.js
		#cp files/mozilla.cfg /usr/lib/firefox/mozilla.cfg

		#printf "<!> Run the corresponding CIS script now\n" # need to figure out config settings
		# if [[ $os_version =~ "Ubuntu16" ]]
		# then
		#	 cis_ubu16
		# elif [[ $os_version =~ "Ubuntu18" ]]
		# then
		#	 cis_ubu18
		# fielif [[ $os_version =~ "Ubuntu20" ]]
		# then
		#	 cis_ubu20
		# fi
		#pause_script

		printf "<*> Proceeding with Auditing and Mischellaneous"
		sudo chmod 640 /etc/shadow
	    gsettings set org.gnome.desktop.screensaver lock-enabled true
	    gsettings set org.gnome.desktop.session idle-delay 300
	    gsettings set org.gnome.desktop.screensaver lock-delay 0
	    gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false
		gconftool-2 -s -t bool /desktop/gnome/remote_access/enabled false
		sudo apt-get purge -y vino remmina remmina-common
		
		sudo apt-get install -y logwatch
		lwloc=$(ls /etc/cron.daily/ | grep logwatch)
		sudo mv /etc/cron.daily/$lwloc /etc/cron.weekly/
		sudo apt-get install -y acct
		sudo touch /var/log/wtmp

		echo "kernel.randomize_va_space=1" >> /etc/sysctl.conf
    	# Enable IP spoofing protection
    	echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
		# Disable IP source routing
    	echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
       	# Ignoring broadcasts request
    	echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf
    	# Make sure spoofed packets get logged
    	echo "net.ipv4.conf.all.log_martians=1" >> /etc/sysctl.conf
    	echo "net.ipv4.conf.default.log_martians=1" >> /etc/sysctl.conf
    	# Disable ICMP routing redirects
    	echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.conf
    	echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf
    	echo "net.ipv4.conf.all.send_redirects=0" >> /etc/sysctl.conf
    	# Disables the magic-sysrq key
    	echo "kernel.sysrq=0" >> /etc/sysctl.conf
    	# Turn off the tcp_timestamps
    	echo "net.ipv4.tcp_timestamps=0" >> /etc/sysctl.conf
    	# Enable TCP SYN Cookie Protection
    	echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf
    	# Enable bad error message Protection
    	echo "net.ipv4.icmp_ignore_bogus_error_responses=1" >> /etc/sysctl.conf
    	sysctl -w net.ipv4.ip_forward=0
    	sysctl -w net.ipv4.conf.default.send_redirects=0
    	sysctl -w net.ipv4.conf.default.accept_redirects=0
    	sysctl -w net.ipv4.conf.all.secure_redirects=0
    	sysctl -w net.ipv4.conf.default.secure_redirects=0
    	sudo sed -i '$a net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf
    	sudo sed -i '$a net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf
    	sudo sed -i '$a net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf
    	sudo sed -i '$a net.ipv4.tcp_max_syn_backlog = 2048' /etc/sysctl.conf
    	sudo sed -i '$a net.ipv4.tcp_synack_retries = 2' /etc/sysctl.conf
    	sudo sed -i '$a net.ipv4.tcp_syn_retries = 5' /etc/sysctl.conf
		# RELOAD WITH NEW SETTINGS
    	sudo /sbin/sysctl -p
    	
    	sudo find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -group root -type f ! -perm /2000 -exec chgrp root '{}' \;
    	sudo systemctl mask ctrl-alt-del.target
    	sudo systemctl daemon-reload
    	if [[ $(ls /etc/ | grep -ic pam_pkcs11) -eq 0 ]];then sudo mkdir -p /etc/pam_pkcs11/;fi
    	sudo cp -TRv ConfigFiles/pam_pkcs11.conf /etc/pam_pkcs11/pam_pkcs11.conf
    	#Might need sudo systemctl disable exim4
    	#This as well sudo apt-get remove exim4 exim4-base exim4-config exim4-daemon-light
    	sudo systemctl disable avahi-daemon
    	passwd="bruh"
    	sudo sed -i '$i set superusers=\"root\"\npassword root $passwd' /etc/grub.d/40_custom
    	sudo update-grub
    	sudo cp -TRv ConfigFiles/greeter.dconf-defaults /etc/gdm3/greeter.dconf-defaults
    	sudo timedatectl set-timezone UTC

    	#Starting to audit ubuntu
		sudo apt install -y auditd audispd-plugins aide
    	sudo auditd -s enable
    	sudo cp -TRv ConfigFiles/audit.rules /etc/audit/rules.d/audit.rules
    	sudo chmod 640 /etc/audit/rules.d/audit.rules
    	sudo cp -TRv ConfigFiles/aide.conf /etc/aide/aide.conf
    	sudo chmod 644 /etc/aide/aide.conf
    	#Used to offload audit log to outside server
    	#sudo sed -i -E 's/active\s*=\s*no/active = yes/' /etc/audisp/plugins.d/au-remote.conf
    	#sudo sed -i -E 's/(remote_server\s*=).*/\1 <remote addr>/' /etc/audisp/audisp-remote.conf
    	sudo chown -R :root /etc/audit/auditd.conf /etc/audit/audit.rules /etc/audit/audit.rules.prev /etc/audit/audit-stop.rules /etc/audit/rules.d/audit.rules #name of rules file might change
    	sudo augenrules --load
    	sudo systemctl restart auditd.service
    	
    	sudo stat -c "%n %a" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd /sbin/augenrules
    	printf "<*> Make sure there are none with a more permissive mode than 755, if there is, use chmod to put it back to 755"
    	pause_script 
    	sudo stat -c "%n %G" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd /sbin/augenrules 
    	printf "<*> Make sure that all these files are owned by root, if not then change it to root using sudo chown :root [audit_tool]"
    	pause_script
    	sudo stat -c "%n %U" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/audispd /sbin/augenrules
    	printf "<*> Make sure that all these files are owned by root, if not use sudo chown root [audit_tool]"
    	pause_script

    	sudo find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -perm /022 -type d -exec chmod -R 755 '{}' \;
    	sudo find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -type d -exec chown root '{}' \;
    	sudo find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -group root -type d -exec chgrp root '{}' \;
    	sudo chown root /var/log/audit/* #might need to change depending on log locations: find log locations using sudo grep -iw log_file /etc/audit/auditd.conf | awk '{print $3}'
    	sudo chmod 0600 /var/log/audit/* #might change depending on audit log location
    	sudo chown :root /var/log/audit/ 
    	sudo sed -i '/^log_group/D' /etc/audit/auditd.conf #these two may not be necessary idk yet
		sudo sed -i /^log_file/a'log_group = root' /etc/audit/auditd.conf 
		sudo systemctl kill auditd -s SIGHUP
		sudo systemctl restart auditd 
    	sudo chmod -R g-w,o-rwx /var/log/audit #might change depepdning on audit log location
    	if [[ $(sudo grep "^\s*linux" /boot/grub/grub.cfg | grep -ic audit=1) -eq 0 ]]
    	then 
    		sudo sed -i '/GRUB_CMDLINE_LINUX=/ s/.$//' /etc/default/grub
			sudo sed -i '/GRUB_CMDLINE_LINUX=/ s/$/ audit=1"/' /etc/default/grub
			sudo update-grub
    	fi
    	cd /tmp; sudo apt download aide-common
    	sudo dpkg-deb --fsys-tarfile /tmp/aide-common_*.deb | sudo tar -x ./usr/share/aide/config/cron.daily/aide -C / 
    	sudo cp -f /usr/share/aide/config/cron.daily/aide /etc/cron.daily/aide
    	sudo passwd -l root # you can reverse this by using sudo passwd -u root
		decide
	fi			
}

decide