#!/bin/bash
#
#   Program:    BASH Ubuntu Security Scipts FuresEthicam
#   File:       masteredUbuntuScript.sh
#   Author:     tentaclsion && hyped||4everalone
#
#********************************************************************
#Color values for printf and no color value
BLUE="\e[94m"
RED="\e[91m"
YELLOW="\e[93m"
GREEN="\e[92m"
NC="\e[0m"

# Fures Ethicam Logo
printf " \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\  \\\\\\\\      \\\\\\\\\\\\\\\\\\\\\\\\\\    \\\\\\\\\\\\\\\\\\\\\\\\\\\\   \\\\\\\\\\\\\\\\\\\\\\\\\\n"
printf "   ||||||  ||       |||||||  \\||||||/  ||||||\n"
printf "           ||             ||          ||\n"
printf "           ||            /|| ||||||||  |||||||\n"
printf " ||||||||  ||      //  |||\\                  ||\n"
printf " ||        \\|\\    /||   ||                    |/\n"
printf " ||         \\||||||/     ||  /||||||/    |||||/\n\n"
printf "            |||||||| ||||||     ||   \\     /||||/      |\n"
printf "                     ||         ||   ||  |||    ||    ||| |        ||\n"
printf "                     ||         ||   || ||           ||||  ||    ||||\n"
printf "            |||||||| ||  /||||||||   || ||          ||/\\||  |||||| ||\n"
printf "                     || ||      ||   || ||         ||    ||   ||   ||\n"
printf "                     || ||      ||   ||  |||       ||              ||\n"
printf "            /||||||| || ||      ||   /     |||||  ||       ||      ||\n"

printf "$GREEN<*> Ubuntu Security Scripts Started\n$NC"

#SCRIPT SUGGESTIONS:
    #Find way to turn off screen sharing through terminal
    #Policies for system updates should be automated
    #Possibly find way to add new trusted software provider key file ***ONLY IF REALLY DESPERATE***
    #New repo addition might be necessary
    #Make sure the kernel is always updated
    #possibly new driver installations
    #New pamlib modules and change passwd requirements
    #Installing new pamlib modules could fix compatibility issues
    #Add option to remove located media files
    #CHANGE LOGIN RETRIES AMOUNT AND LOGIN TIMEOUT
    #FIX SED AS IT DOES NOT EDIT THE APPROPRIATE LINE
    #CHANGE USER MANAGEMENT SECTION
    #Possibly look through ps aux results to find odd processes
    #Don't forget firefox settings bruh
    #Disable sambda if necessary, if not secure it
    #Uninstall ALLLLLLLLLLLLLLLLLLLLLLLLLLLL games
    #Java or Python may or may not be uninstalled
    #Uninstall ImageMagik
    #Maybe install ClamTK through software center to make sure it works
    #LOCK THE SCREEN
    #Security and privacy inside system settings
    #Automatic Backups might give points: Inside settings kek
    #Details inside of settings may give points in later rounds especially for software
    #Change inactivity settings in Power under all settings
    #Check for malware backdoors on ubuntu, look for alternatives to clam scan, may or may not work
    #Remove unwanted files and install the appropriate apps such as password managers
    #Uninstall unallowed applications INCLUDING GAMES LUILULU no valorant
    #Might need to remove floppy disc access through settings and through terminal if ubu 18
    #Also, don't forget about Lynis, could be potentially useful
    #REMOVE FTP Stup
sudo passwd -l root
username=$(whoami)
#Updates/Upgrades
printf "$RED<*> Change Update Policies First$NC"
printf "$BLUE<*> Update system files <Y|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    printf "$GREEN<*> Updating...$NC\n"
    sudo add-apt-repository -y ppa:libreoffice/ppa
    sudo apt-get -y update
fi
#Upgrading System Software
printf "$BLUE<*> Upgrade system software <Y|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #Set "install security updates"
    cat /etc/apt/sources.list | grep "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted"
    if [ $? -eq 1 ]
    then
        echo "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted" >> /etc/apt/sources.list
    fi
    printf "$GREEN<*> Upgrading...$NC\n"
    sudo apt-get -y upgrade
    killall firefox
    printf "$RED<*> Do not forget Firefox settings$NC"
    sudo apt-get --purge --reinstall install firefox -y
    #Sets default broswer
    sed -i 's/x-scheme-handler\/http=.*/x-scheme-handler\/http=firefox.desktop/g' /home/$USER/.local/share/applications/mimeapps.list
    #sudo update-alternatives --config x-www-browser
    #grep "/usr/bin/firefox" | cut -c -18
fi
#Updating Kernel Version
kernelVersion=$(uname -sr)
printf "$BLUE<*> Upgrade Kernel Version <Y|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    printf "$GREEN<*> Upgrading Kernel Version$NC\n"
    sudo apt-get dist-upgrade -y
    sudo update-manager -d
#Enabling Firewall
printf "$BLUE<*> Activate and Install Firewall <Y|N>:$NC\n"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #Using UFW for a general firewall but use IPTABLES for specific
    printf "$RED<*> Using UFW for a general firewall but use IPTABLES for specific"
    printf "$BLUE<*> Installing Firewall...$NC\n"
    sudo apt-get install ufw
    printf "$YELLOW<*> Enabling Firewall...$NC\n"
    sudo ufw enable
fi
#Typical LightDM configs; disallow guest account etc
printf "$BLUE<*> Enforce typical lightDM policies <Y|N>:$NC"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    if [[ -f /etc/lightdm/lightdm.conf ]]
    then
        sed -i '$a allow-guest=false' /etc/lightdm/lightdm.conf
        sed -i '$a greeter-hide-users=true' /etc/lightdm/lightdm.conf
        sed -i '$a greeter-show-manual-login=true' /etc/lightdm/lightdm.conf
        #Checking for auto-login user and disabling if found
        cat /etc/lightdm/lightdm.conf | grep autologin-user >> /dev/null
        if [ $? -eq 0 ]
        then
            autoUser=$(cat /etc/lightdm/lightdm.conf | grep autologin-user | cut -d= -f2)
            echo $autoUser
            if [ "$autoUser" != "none" ]
            then
                printf "$YELLOW $autoUser is set to autologin lululul $NC"
                sed -i 's/autologin-user=.*/autologin-user=none/' /etc/lightdm/lightdm.conf
            fi
        else
            sed -i '$a autologin-user=none' /etc/lightdm/lightdm.conf
        fi
        printf "$YELLOW<*>Looking over the lightdm config file to ensure changes have been made...$NC"
        pause
        cat /etc/lightdm/lightdm.conf
    else
        touch /etc/lightdm/lightdm.conf
        sed -i '$a [SeatDefault]' /etc/lightdm/lightdm.conf
        sed -i '$a allow-guest=false' /etc/lightdm/lightdm.conf
        sed -i '$a greeter-hide-users=true' /etc/lightdm/lightdm.conf
        sed -i '$a greeter-show-manual-login=true' /etc/lightdm/lightdm.conf
        #Checking for auto-login user and disabling if found
        cat /etc/lightdm/lightdm.conf | grep autologin-user >> /dev/null
        if [ $? -eq 0 ]
        then
            autoUser=$(cat /etc/lightdm/lightdm.conf | grep autologin-user | cut -d= -f2)
            echo $autoUser
            if [ "$autoUser" != "none" ]
            then
                printf "$YELLOW $autoUser is set to autologin lululul $NC"
                sed -i 's/autologin-user=.*/autologin-user=none/' /etc/lightdm/lightdm.conf
            fi
        else
            sed -i '$a autologin-user=none' /etc/lightdm/lightdm.conf
        fi
        printf "$YELLOW<*>Looking over the lightdm config file to ensure changes have been made...$NC"
        pause
        cat /etc/lightdm/lightdm.conf
    fi
fi
#Fixed Password Policies, at least hopefully
printf "$BLUE<*> Install and Config passwd policies <Y|N>:$NC"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get install libpam-cracklib -y
    sed -i -e 's/PASS_MAX_DAYS\t[[:digit:]]\+/PASS_MAX_DAYS\t90/' /etc/login.defs
    sed -i -e 's/PASS_MIN_DAYS\t[[:digit:]]\+/PASS_MIN_DAYS\t10/' /etc/login.defs
    sed -i -e 's/PASS_WARN_AGE\t[[:digit:]]\+/PASS_WARN_AGE\t7/' /etc/login.defs
    #Potential area to expand on for future rounds
    sed -i -e 's/difok=3\+/difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
    printf "$YELLOW<*> Setting account lockout policies$NC"
    sed -i 's/auth\trequisite\t\t\tpam_deny.so\+/auth\trequired\t\t\tpam_deny.so/' /etc/pam.d/common-auth
    sed -i '$a auth\trequired\t\t\tpam_tally2.so deny=5 unlock_time=1800 onerr=fail' /etc/pam.d/common-auth
    sed -i 's/sha512\+/sha512 remember=13/' /etc/pam.d/common-password
fi
#User Management
declare -a hiddenUser
declare -a users
hiddenUser=$(cut -d: -f1,3 /etc/passwd | egrep ':[0]{1}$' | cut -d: -f1)
users=($(cut -d: -f1,3 /etc/passwd | egrep ':[0-9]{4}$' | cut -d: -f1))
echo "$hiddenUser is a hidden user"
printf "$BLUE<*> Delete unauthorized users <Y|N>:$NC"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for user in $users
    do
        printf "$YELLOW<*> Is $user an authorized user <Y|N>:$NC"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]
        then
            sudo userdel -r $user
        fi
    done
    for user in $users
    do
        printf "$YELLOW<*> Is $user an admin user <Y|N>:$NC"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo usermod -a -G adm $user
            sudo usermod -a -G sudo $user
        elif [[ $REPLY =~ ^[Nn]$ ]]
        then
            sudo deluser $user adm
            sudo deluser $user sudo
        fi
    done
    printf "$YELLOW<*> Checking if user have their appropriate role...$NC"
    adminUsers=$(cat /etc/group | grep sudo | cut -d: -f4 | tr ',' ' ')
    for user in $users
    do
        printf "$YELLOW<*> Should $user an admin user <Y|N>:$NC"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]
        then
            sudo deluser $user adm
            sudo deluser $user sudo
        else
            echo -e "$GREEN<*> User $user is already an admin.$NC"
        fi
    done
fi
printf "$RED<*> Don't forget to ADD appropriate users$NC"
#Auditing in Ubuntu... Good luck
printf "$BLUE<*> Install Auditing <I|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ii]$ ]]
then
    printf "$RED<*> Installing Auditd...$NC\n"
    sudo apt install -y auditd audispd-plugins
    auditd -s enable
fi
#ANTIVIRUS - ClamAV installation
printf "$RED<*> MIGHT NEED TO INSTALL THROUGH SOFTWARE TERMINAL TO GET POINTS$NC"
printf "$BLUE<*> Install ClamAV Along with Dependbable Programs <I|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ii]$ ]]
then
    sudo apt-get install build-essential
    sudo apt-get install openssl libssl-dev libcurl4-openssl-dev zlib1g-dev libpng-dev libxml2-dev libjson-c-dev libbz2-dev libpcre3-dev ncurses-dev
    sudo apt-get install libmilter1.0.1 libmilter-dev
    sudo apt-get install valgrind check
    printf "$RED<*> Installing ClamAV...$NC\n"
    sudo apt-get install -y clamav clamav-daemon
    sudo freshclam
    sudo apt-get intall clamtk -y
fi
printf "$BLUE<*> Remove all malicious files/viruses <R|S>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Rr]$ ]]
then
    gnome-terminal -x sh -c "clamscan -r --remove /; bash"
elif [[ $REPLY =~ ^[Ss]$ ]]
then
    gnome-terminal -x sh -c "clamscan -r --bell -i /; bash"
fi

#TRY AUTOMATIC UPDATES
printf "$RED<*> If policies have not yet been enebled, enable now...$NC\n"
printf "$BLUE<*> Attempt to install automatic updates <Y|N>:$NC\n"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    printf "$YELLOW<*> Enabling Automatic Updates (Trying)$NC\n"
    sudo apt-get install unattended-upgrades
    if [[ -f /etc/apt/apt.conf.d/10periodic ]]
        #Set daily updates
        sed -i -e 's/APT::Periodic::Update-Package-Lists.*\+/APT::Periodic::Update-Package-Lists "1";/' /etc/apt/apt.conf.d/10periodic
        sed -i -e 's/APT::Periodic::Download-Upgradeable-Packages.*\+/APT::Periodic::Download-Upgradeable-Packages "0";/' /etc/apt/apt.conf.d/10periodic
        echo "$RED<*> Automatic Updates"
        cat /etc/apt/apt.conf.d/10periodic
        echo ""
        echo "$RED<*> Important Security Updates"
        cat /etc/apt/sources.list
    elif [[ -f /etc/apt/apt.conf.d/50auto-upgrades ]]
    then
        sudo cp /etc/apt/apt.conf.d/50auto-upgrades /etc/apt/apt.conf.d/50auto-upgrades.bak
        sudo rm /etc/apt/apt.conf.d/50auto-upgrades
        echo "APT::Periodic::Update-Package-Lists \"1\";
        APT::Periodic::Download-Upgradeable-Packages \"1\";
        APT::Periodic::AutocleanInterval \"30\";
        APT::Periodic::Unattended-Upgrade \"1\";" | sudo tee --append /etc/apt/apt.conf.d/50auto-upgrades
        sudo sed -i 's=//${*}:${*}-updates;=${*}:${*}-updates;' /etc/apt/apt.conf.d/50unattended-upgrades
    fi
    /etc/init.d/unattended-upgrades restart
fi

printf "$RED<*> Only works with Ubuntu 18 and Remember to copy Root passwd to notepad or something lol$NC\n"
printf "$BLUE<*> Set automatic screensaver <Y|N>:$NC\n"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    gsettings set org.gnome.desktop.screensaver lock-enabled true
    gsettings set org.gnome.desktop.session idle-delay 300
    gsettings set org.gnome.desktop.screensaver lock-delay 0
fi


#Uninstalling Games
printf "$RED<*> Still look through manually to find other games$NC"
printf "$BLUE<*> Uninstalling games found on the system...$NC"


#Installing basic applications
#MySql
printf "$BLUE<*> Install/Uninstall MySQL <I|U|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ii]$ ]]
then
    printf "$YELLOW<*> Installing MySQL...$NC\n"
    sudo apt-get -y install mysql-server
    printf "$YELLOW<*> Disabling remote access...$NC\n"
    sudo sed -i "/bind-address/ c\bind-address = 127.0.0.1" /etc/mysql/my.cnf
    printf "$YELLOW<*> Restarting MySQL...$NC\n"
    sudo service mysql restart
elif [[ $REPLY =~ ^[Uu]$ ]]
then
    sudo apt-get -y purge mysql*
fi

# OpenSSH
printf "$BLUE<*> Install/Uninstall OpenSSH <I|U|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ii]$ ]]
then
    printf "$YELLOW<*> Installing OpenSSH...$NC\n"
    sudo apt-get -y install openssh-server
    printf "$YELLOW<*> Configuring SSh security...$NC\n"
    #/etc/ssh/ssh_config
    #ssh config-should check if openssh is installed to automatically set up Configuring
    #switch port 22;protocol ssh 2;permit root login no; passwordAuthentication no;permitEmptyPasswords no;clientAliveInterval 360(seconds);clientAliveCountMax 0; AllowTcpForwarding no; X11Forwarding no; restrict certain ip addresses
    #set up firewall for the chosen ssh port
    #***THINK OF USING FAIL2BAN***
    sudo sed -i "/^#PermitRootLogin/ c\PermitRootLogin no" /etc/ssh/sshd_config
    sudo sed -i "/^#Port/ c\Port 22" /etc/ssh/sshd_config
    sudo sed -i "/^#PasswordAuthentication/ c\PasswordAuthentication no" /etc/ssh/sshd_config
    sudo sed -i "/^#PermitEmptyPasswords/ c\PermitEmptyPasswords no" /etc/ssh/sshd_config
    sudo sed -i "/^#ClientAliveInterval/ c\ClientAliveInterval 360" /etc/ssh/sshd_config
    sudo sed -i "/^#ClientAliveCountMax/ c\ClientAliveCountMax 0" /etc/ssh/sshd_config
    sudo sed -i "/^#AllowTcpForwarding/ c\AllowTcpForwarding no" /etc/ssh/sshd_config
    sudo sed -i "/^#X11Forwarding/ c\X11Forwarding no" /etc/ssh/sshd_config
    sudo echo -e "Protocol 2" | sudo tee --append /etc/ssh/sshd_config
    printf "$YELLOW<*> Restarting Server...$NC\n"
    sudo service ssh restart
    sudo ufw allow 22
elif [[ $REPLY =~ ^[Uu]$ ]]
then
    sudo apt-get -y purge openssh-server*
fi

# VSFTPD
printf "$BLUE<*> Install/Uninstall VSFTPD <I|U|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Ii]$ ]]
then
    printf "$YELLOW<*> Installing VSFTPD...$NC\n"
    sudo apt-get -y install vsftpd
    printf "$YELLOW<*> Disabling$RED ANONYMOUS$YELLOW uploads...$NC\n"
    sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
    sudo sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
    printf "$YELLOW<*> Configuring FTP directories...$NC\n"
    sudo sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
    printf "$YELLOW<*> Restarting VSFTPD...$NC\n"
    sudo service vsftpd restart
elif [[ $REPLY =~ ^[Uu]$ ]]
then
    sudo apt-get -y purge vsftpd*
fi

#Attempting to Remove Remote Desktop
printf "$RED<*> Still disable remote desktop through GUI as this may only work with Ubuntu 18$NC"
printf "$BLUE<*> Disabling remote desktop sharing$NC\n"
gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false
gconftool-2 -s -t bool /desktop/gnome/remote_access/enabled false
sudo apt-get purge -y vino remmina remmina-common

# Remove Malware
malware=(hydra john medusa netcat nmap ophcrack wireshark* bitTorrent transmission* zenmap* aircrack-ng maltego nessus snort kismet sqlmap nikto yersinia hashcat beef macchanger dsniff tcpdump)   # Add additional programs here
printf "$BLUE   Malware List\n$NC"
printf "$YELLOW    --------------------$NC\n"
for prog in ${malware[@]}
do
    printf "$YELLOW $prog $NC\n"
done
printf "$BLUE<*> Purge malware from system <Y|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for prog in ${malware[@]}
    do
        sudo apt-get -y purge $prog*
        sudo apt-get -y autoremove --purge $prog*
    done
fi

# Manage Media Files
endings=(aac wav mp3 mp4 wma mov avi gif jpg png bmp pdf txt img iso exe msi bat sh tar.gz php)    # Add additional suffix here REMOVE FILES ADD YES OR NO WHETHER TO REMOVE OR NOT
printf "$BLUE   Suffix List\n$NC"
printf "$YELLOW    -------------------$NC\n"
for suffix in ${endings[@]}
do
    printf "$YELLOW $suffix $NC\n"
done
printf "$RED<*> Don't forget to uninstall malicious files, WILL NOT BE DONE AUTOMATICALLY...OkMaybe It will $NC"
printf "$BLUE<*> Locate media files <Y|N>:$NC "
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    for suffix in ${endings[@]}
    do
        sudo find /home -name *.$suffix
    done
    printf "$BLUE<*> Specific File Cases"
    sudo find / -name "*backdoor*.*"
    sudo find / -name "*backdoor*.php"
    sudo find / -nogroup
    sudo find / -name "*.mp3" -type f -delete
    sudo find / -name "*.mov" -type f -delete
    sudo find / -name "*.mp4" -type f -delete
    sudo find / -name "*.jpg" -type f -delete
    sudo find / -name "*.jpeg" -type f -delete
fi

printf "$BLUE<*> Modifying sysctl.conf$NC"
##Disables IPv6
sed -i '$a net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf
sed -i '$a net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf
sed -i '$a net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf
##Disables IP Spoofing
sed -i '$a net.ipv4.conf.all.rp_filter=1' /etc/sysctl.conf
##Disables IP source routing
sed -i '$a net.ipv4.conf.all.accept_source_route=0' /etc/sysctl.conf
##SYN Flood Protection
sed -i '$a net.ipv4.tcp_max_syn_backlog = 2048' /etc/sysctl.conf
sed -i '$a net.ipv4.tcp_synack_retries = 2' /etc/sysctl.conf
sed -i '$a net.ipv4.tcp_syn_retries = 5' /etc/sysctl.conf
sed -i '$a net.ipv4.tcp_syncookies=1' /etc/sysctl.conf
##IP redirecting is disallowed
sed -i '$a net.ipv4.ip_foward=0' /etc/sysctl.conf
sed -i '$a net.ipv4.conf.all.send_redirects=0' /etc/sysctl.conf
sed -i '$a net.ipv4.conf.default.send_redirects=0' /etc/sysctl.conf
sysctl -p
#Disabling CTRL-ALT-DEL
printf "$BLUE<*> Disabling CTRL-ALT-DEL$NC"
sed -i '/exec shutdown -r now "Control-Alt-Delete pressed"/#exec shutdown -r not "Control-Alt-Delete pressed"/' /etc/init/control-alt-delete.conf
# Disable floppy
printf "$YELLOW<*> Disabling floppy...$NC\n"
echo -e "blacklist floppy" | sudo tee /etc/modprobe.d/blacklist-floppy.conf
sudo rmmod floppy
sudo update-initramfs -u
#Securing /etc/shadow file
chmod 640 /etc/shadow
ls -l /etc/shadow
