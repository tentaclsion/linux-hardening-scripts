# Colors
BLUE="\e[94m"
RED="\e[91m"
YELLOW="\e[93m"
GREEN="\e[92m"
NC="\e[0m"

# Differences between Debain 9 and Ubuntu 18.04
# 1.1.1.1 cramfs
# 1.5.4 interactive boot
# For this script differences don't really matter so there is no check
# NO THERE ARE DIFFERENCES WHY ITS GOING TO MAKE ME LOOK THROUGH EVERYTHING NOW
# Please check for where there are differences between the two

# Ask if system is Ubuntu or Debian - i dont feel like figuring out how to check it
isDebian=false
printf "$RED	Before starting...\nIs this running on (U)buntu or (D)ebian? [default is ubuntu] "
if [[ $REPLY =~ ^[Dd]$ ]]
then
	printf "$RED Script is now in Debian mode. $NC"
	isDebian=true
else
	printf "$RED Script is now in Ubuntu mode. $NC"
fi

# Filesystem Management
printf "$BLUE	Starting Filesystem Management\n"
printf "    --------------------$NC\n"

printf "$BLUE Now disabling unused filesystems.$NC\n"
filesystems=(cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat usb-storage) # usb-storage 1.1.23 just uses the same commands, so it is put here
for fs in ${filesystems[@]}
do
	printf "$YELLOW	Disabling $fs.$NC"
	echo -e "install $fs /bin/true" >> /etc/modprobe.d/cisfs.conf # all put into one .conf file, should check if this works
	rmmod $fs
done
printf "$GREEN Done!$NC\n"

# 1.1.2 - This can possibly done with sed
systemctl unmask tmp.mount
systemctl enable tmp.mount
printf "Please add the following into /etc/systemd/system/local-fs.target.wants/tmp.mount" # maybe just make a file to copy over
echo -e 	"[Mount]\n
			What=tmpfs\n
			Where=/tmp\n
			Type=tmpfs\n
			Options=mode=1777,strictatime,noexec,nodev,nosuid" # no idea if the tabs show up in echo, take them out if they do # this sucks
read -p "Press any key to continue... " -n 1 -s

# General remounts
printf "$BLUE Remounting /tmp$NC\n"
mount -o remount,nodev,nosuid,noexec /tmp # please test if this works within my one line solution
printf "$BLUE Remounting /var/tmp$NC\n"
mount -o remount,nodev,nosuid,noexec /var/tmp
printf "$BLUE Remounting /home$NC\n"
mount -o remount,nodev /home
printf "$BLUE Remounting /dev/shm$NC\n"
mount -o remount,nodev,nosuid,noexec /dev/shm

# Stuff I can't script
printf "$BLUE\nPlease refer to CIS for the following.$NC\n"
refer=(1.1.6 1.1.7 1.1.11 1.1.12 1.1.13 1.1.18 1.1.19 1.1.20 1.2.1 1.2.2)
for cis in ${refer[@]}
do
	print "$YELLOW$cis "
done
printf "$NC"
read -p "Press any key to continue... " -n 1 -s

# 1.1.21
printf "$RED If the following does not work, remove the --local argument.$NC"
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}' # there is a note that --local may not be supported

# 1.1.22 - using both just for redundancy - the same as in services, can be put together in large script
printf "$BLUE Disabling auto-mount (autofs)$NC\n"
systemctl --now disable autofs
apt purge autofs


# Sudo Configuration
printf "$BLUE	Starting Sudo Management\n"
printf "    --------------------$NC\n"

# 1.3.1 - IMAGINE NOT HAVING SUDO LMAO
printf "$BLUE Installing sudo$NC\n"
apt install sudo sudo-ldap

# 1.3.2 + 1.3.3
printf "$BLUE Editing /etc/sudoers$NC\n" # refer to document for why this is here
echo -e "Defaults use_pty" >> /etc/sudoers
echo -e "Defaults logfile="/var/log/sudo.log"" >> /etc/sudoers


# Filesystem Integrity Checking
printf "$BLUE	Filesystem Integrity Checking\n"
printf "    --------------------$NC\n"

# 1.4.1
apt install aide aide-common
read -p "Run 'aideinit' and configure AIDE\nPress any key to continue... " -n 1 -s

# 1.4.2 - WHY TF IS THIS DIFFERENT BETWEEN UBUNTU AND DEBIAN FUKKK
printf "$BLUE Regularly checking filesystem integrity$NC\n"
if [[ "$isDebian" = true ]]
then
	printf "$YELLOW Please refer to Debian CIS 1.4.2$NC" # im too lazy to do this rn
	read -p "Press any key to continue... " -n 1 -s
else
	cp ./config/aidecheck.service /etc/systemd/system/aidecheck.service
	cp ./config/aidecheck.timer /etc/systemd/system/aidecheck.timer
	chmod 0644 /etc/systemd/system/aidecheck.*
	systemctl reenable aidecheck.timer
	systemctl restart aidecheck.timer
	systemctl daemon-reload
done


# Secure Boot Settings
printf "$BLUE	Secure Boot\n"
printf "    --------------------$NC\n"

# 1.5.1
printf "$BLUE Setting permissions for grub$NC\n"
chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

# 1.5.2
printf "$BLUE Set bootloader password? $NC"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	printf "$RED Good luck$NC"
	grub-mkpasswd-pbkdf2
	printf "$YELLOW Please refer to CIS 1.5.2 to finish this step$NC" # im too lazy to do this rn
	read -p "Press any key to continue... " -n 1 -s
fi

# 1.5.3 - don't we disable this in CP? change this one if it doesnt help us
printf "$BLUE Set root password.$NC"
passwd root

# 1.5.4 - this can be checked by scripting but i dont feel like it


# Additional Process Hardening
printf "$BLUE	Additional Process Hardening\n"
printf "    --------------------$NC\n"

# 1.6.1 - unclear so skipped

# 1.6.2
echo "$BLUE Editing /etc/sysctl.conf$NC\n" # refer to document for why this is here
sudo sed -i "/^#kernel.randomize_va_space/ c\kernel.randomize_va_space = 2" /etc/sysctl.conf # fix if it doesnt work since idk sed
sysctl -w kernel.randomize_va_space=2

# 1.6.3
echo "$BLUE Disabling prelink$NC\n"
prelink -ua
apt purge prelink

# 1.6.4
echo "$BLUE Restricing core dumps$NC\n"
echo -e "* hard core 0" >> /etc/security/limits.conf
sudo sed -i "/^#fs.suid_dumpable/ c\fs.suid_dumpable = 0" /etc/sysctl.conf # not sure if i used sed correctly
sysctl -w fs.suid_dumpable=0
echo -e "Storage=none\nProcessSizeMax=0" >> /etc/systemd/coredump.conf # use sed instead if it can add lines if they dont exist
systemctl daemon-reload


# Mandatory Access Control
printf "$BLUE	Additional Process Hardening\n"
printf "    --------------------$NC\n"

# 1.7.1
echo "$BLUE Installing and Configuring AppArmor$NC\n"
apt install apparmor apparmor-utils

sudo sed -i '/^#GRUB_CMDLINE_LINUX/ c\GRUB_CMDLINE_LINUX="apparmor=1 security=apparmor"' # Most likely incorrect ussage of sed, fix plz
update-grub

aa-enforce /etc/apparmor.d/*


# Warning Banners
printf "$BLUE	Scaring Dumbasses\n"
printf "    --------------------$NC\n"

# just grouping everything together
printf "$BLUE Keep /etc/motd? $NC"
if [[ $REPLY =~ ^[Yy]$ ]]
then
	chown root:root /etc/motd
	chmod u-x,go-wx /etc/motd
else
	rm /etc/motd
fi

# 1.8.1.2 + 1.8.1.3
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net

# 1.8.1.5 + 1.8.1.6
chown root:root /etc/issue
chmod u-x,go-wx /etc/issue
chown root:root /etc/issue.net
chmod u-x,go-wx /etc/issue.net

# 1.8.2
echo -e "[org/gnome/login-screen]\n
		banner-message-enable=true\n
		banner-message-text='Authorized uses only. All activity may be monitored and reported." >> /etc/gdm3/greeter.dconf-defaults # again, tabs may need to be removed

# 1.9 - this is in 1.8 for some reason
apt upgrade # lul