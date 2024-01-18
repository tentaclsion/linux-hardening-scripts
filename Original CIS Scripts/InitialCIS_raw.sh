# Differences
# 1.1.1.1 cramfs
# 1.5.4 interactive boot

# filesystems
# disable unused filesystems (there might be mistakes since im tired, but it should be fine)
# 1.1.1.1 - Ubuntu only
echo -e "install cramfs /bin/true" >> /etc/modprobe.d/cramfs.conf # theoretically, all of these can be in the same .conf file
rmmod cramfs

# 1.1.1.2
echo -e "install freevxfs /bin/true" >> /etc/modprobe.d/freevxfs.conf
rmmod freevxfs

# 1.1.1.3
echo -e "install jffs2 /bin/true" >> /etc/modprobe.d/jffs2.conf
rmmod jffs2

# 1.1.1.4
echo -e "install hfs /bin/true" >> /etc/modprobe.d/hfs.conf
rmmod hfs

# 1.1.1.5
echo -e "install hfsplus /bin/true" >> /etc/modprobe.d/hfsplus.conf
rmmod hfsplus

# 1.1.1.6
echo -e "install squashfs /bin/true" >> /etc/modprobe.d/squashfs.conf
rmmod squashfs

# 1.1.1.7
echo -e "install udf /bin/true" >> /etc/modprobe.d/udf.conf
rmmod udf

# 1.1.1.8
echo -e "install vfat /bin/true" >> /etc/modprobe.d/vfat.conf
rmmod vfat

# 1.1.2
systemctl unmask tmp.mount
systemctl enable tmp.mount
echo "Please add the following into /etc/systemd/system/local-fs.target.wants/tmp.mount"
echo -e 	"[Mount]\n
			What=tmpfs\n
			Where=/tmp\n
			Type=tmpfs\n
			Options=mode=1777,strictatime,noexec,nodev,nosuid" # no idea if the tabs show up in echo, take them out if they do
read -p "Press any key to continue... " -n 1 -s

# 1.1.3 - 3-5 can be for each/one line
mount -o remount,nodev /tmp 

# 1.1.4
mount -o remount,nosuid /tmp

# 1.1.5
mount -o remount,noexec /tmp

# 1.1.6 - manual work ugh
echo "Refer to CIS for 1.1.6"

# 1.1.7 - more manual work ugh
echo "Refer to CIS for 1.1.7"

# 1.1.8 - 8-10 can be for each/one line
mount -o remount,nodev /var/tmp

# 1.1.9
mount -o remount,nosuid /var/tmp

# 1.1.10
mount -o remount,noexec /var/tmp

# 1.1.11
echo "Refer to CIS for 1.1.11"

# 1.1.12
echo "Refer to CIS for 1.1.12"

# 1.1.13
echo "Refer to CIS for 1.1.13"

# 1.1.14
mount -o remount,nodev /home

# 1.1.15 - you get the point
mount -o remount,nodev /dev/shm

# 1.1.16
mount -o remount,nosuid /dev/shm

# 1.1.17
mount -o remount,noexec /dev/shm

# 1.1.18
echo "Refer to CIS for 1.1.18"

# 1.1.19
echo "Refer to CIS for 1.1.19"

# 1.1.20
echo "Refer to CIS for 1.1.20"

# 1.1.21
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}' # there is a note that --local may not be supported

# 1.1.22 - using both just for redundancy - the same as in services, can be put together in large script
systemctl --now disable autofs
apt purge autofs

# 1.1.23 - the same as in services
install usb-storage /bin/true
rmmod usb-storage


# Software Updates - mostly useless
# 1.2.1
echo "The following can be ignored."
echo "Refer to CIS 1.2.1"

# 1.2.2
echo "The following can be ignored."
echo "Refer to CIS 1.2.2"


# sudo
# 1.3.1 - IMAGINE NOT HAVING SUDO LMAO
apt install sudo sudo-ldap

# 1.3.2
echo "Editing /etc/sudoers" # refer to document for why this is here
echo -e "Defaults use_pty" >> /etc/sudoers

# 1.3.3
echo "Editing /etc/sudoers" # refer to document for why this is here
echo -e "Defaults  logfile="/var/log/sudo.log"" >> /etc/sudoers

# Filesystem Integrity Checking
# 1.4.1
apt install aide aide-common
read -p "Run 'aideinit' and configure AIDE\nPress any key to continue... " -n 1 -s

# 1.4.2 - there is also a simpler crontab version, opted to use other bc cp is more likely to ask for these commands
cp ./config/aidecheck.service /etc/systemd/system/aidecheck.service
cp ./config/aidecheck.timer /etc/systemd/system/aidecheck.timer
chmod 0644 /etc/systemd/system/aidecheck.*
systemctl reenable aidecheck.timer
systemctl restart aidecheck.timer
systemctl daemon-reload

# Secure Boot
# 1.5.1
chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg

# 1.5.2 - MAKE THIS A YES/NO THING PLEASE: ITS THE BOOTLOADER PASSWORD
grub-mkpasswd-pbkdf2
# idk what it means by the second thing, please figure it out later

# 1.5.3
passwd root

# 1.5.4 - Ubuntu only
# bruh it just says "if thing is enabled, disable it"


# Additional Process Hardening
# 1.6.1
# install a kernel or somethin

# 1.6.2
echo "Editing /etc/sysctl.conf" # refer to document for why this is here
sudo sed -i "/^#kernel.randomize_va_space/ c\kernel.randomize_va_space = 2" /etc/sysctl.conf # fix if it doesnt work since idk sed
sysctl -w kernel.randomize_va_space=2

# 1.6.3
prelink -ua
apt purge prelink

# 1.6.4 - dont feel like adding 'editing' message anymore
echo -e "* hard core 0" >> /etc/security/limits.conf
sudo sed -i "/^#fs.suid_dumpable/ c\fs.suid_dumpable = 0" /etc/sysctl.conf # not sure if i used sed correctly
sysctl -w fs.suid_dumpable=0
echo -e "Storage=none\nProcessSizeMax=0" >> /etc/systemd/coredump.conf # use sed instead if it can add lines if they dont exist
systemctl daemon-reload


# Mandatory Access Control
# 1.7.1.1
apt install apparmor apparmor-utils

# 1.7.1.2
sudo sed -i '/^#GRUB_CMDLINE_LINUX/ c\GRUB_CMDLINE_LINUX="apparmor=1 security=apparmor"' # Most likely incorrect ussage of sed, fix plz
update-grub

# 1.7.1.3 - i'm not sure which is needed, but its one or the other, maybe add an if statement
aa-enforce /etc/apparmor.d/*
# OR
aa-complain /etc/apparmor.d/*

# 1.7.1.4 - OF FUCKING COURSE THIS REDUNDANCY ANSWERS MY PREVIOUS QUESTION
aa-enforce /etc/apparmor.d/*


# Warning Banners
# why are these needed lmao
# 1.8.1.1
rm /etc/motd # easy solution, possibly issue with readme though but most likely not

# 1.8.1.2
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue

# 1.8.1.3
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net

# 1.8.1.4 - oh... i, uh, deleted it earlier so this may not be needed
chown root:root /etc/motd
chmod u-x,go-wx /etc/motd

# 1.8.1.5
chown root:root /etc/issue
chmod u-x,go-wx /etc/issue

# 1.8.1.6
chown root:root /etc/issue.net
chmod u-x,go-wx /etc/issue.net

# 1.8.2
echo -e 	"[org/gnome/login-screen]\n
			banner-message-enable=true\n
			banner-message-text='Authorized uses only. All activity may be monitored and reported." # again, tabs may need to be removed

# 1.9 - this is in 1.8 for some reason
apt upgrade # lul

# a pause for when we need to read something
#read -p "Press any key to continue... " -n 1 -s