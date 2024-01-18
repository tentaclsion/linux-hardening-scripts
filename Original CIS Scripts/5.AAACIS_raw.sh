# Only compared Ubu 18 to Deb 9

# differences from table of contents
# a bunch of 5.2
# wow i thought there would be more
# tbf i did just glance at the numbers lol

# small note, ubuntu 18 suggests to use the --now option for systemctl while debian does not
# i will exclude it for now but if its an issue we need to add a seperation of the two

# edit 1/21 at 5 in the morning: i didnt check if anything conflicted so have fun
# also add sed stuff since i have no idea how to do it

# 5.1.1 - cron shit
systemctl enable cron

# 5.1.2
chown root:root /etc/crontab
chmod og-rwx /etc/crontab

# 5.1.3
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly

# 5.1.4
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

# 5.1.5
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

# 5.1.6
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly

# 5.1.7
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d

# 5.1.8
rm /etc/cron.deny
rm /etc/at.deny
touch /etc/cron.allow
touch /etc/at.allow
chmod og-rwx /etc/cron.allow
chmod og-rwx /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow


# 5.2 ssh shit - place 'systemctl reload sshd' at the end
# majority ubuntu-debian differences here
# 5.2.1
chown root:root /etc/ssh/sshd_config
chmod og-rwx /etc/ssh/sshd_config

# 5.2.2
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;

# 5.2.3
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 0644 {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;

# 5.2.4 - bruh this doesnt matter for the newer versions of ssh
sudo sed -i "/^#Protocol/ c\Protocol 2" /etc/ssh/sshd_config # sed usage may be incorrect

# 5.2.5
sudo sed -i "/^#LogLevel/ c\LogLevel VERBOSE" /etc/ssh/sshd_config # sed usage may be incorrect

# 5.2.6
sudo sed -i "/^#X11Forwarding/ c\X11Forwarding no" /etc/ssh/sshd_config # sed usage may be incorrect

# 5.2.7
sudo sed -i "/^#MaxAuthTries/ c\MaxAuthTries 4" /etc/ssh/sshd_config

# 5.2.8
sudo sed -i "/^#IgnoreRhosts/ c\IgnoreRhosts yes" /etc/ssh/sshd_config

# 5.2.9
sudo sed -i "/^#HostbasedAuthentication/ c\HostbasedAuthentication no" /etc/ssh/sshd_config

# 5.2.10
sudo sed -i "/^#PermitRootLogin/ c\PermitRootLogin no" /etc/ssh/sshd_config

# 5.2.11
sudo sed -i "/^#PermitEmptyPasswords/ c\PermitEmptyPasswords no" /etc/ssh/sshd_config

# 5.2.12
sudo sed -i "/^#PermitUserEnvironment/ c\PermitUserEnvironment no" /etc/ssh/sshd_config

# 5.2.13
echo -e "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config

# 5.2.14
echo -e "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config

# 5.2.15
echo -e "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config

# 5.2.16
sudo sed -i "/^#ClientAliveInterval/ c\ClientAliveInterval 300" /etc/ssh/sshd_config
sudo sed -i "/^#ClientAliveCountMax/ c\ClientAliveCountMax 0" /etc/ssh/sshd_config

# 5.2.17
sudo sed -i "/^#LoginGraceTime/ c\LoginGraceTime 60" /etc/ssh/sshd_config

# 5.2.18 - MANUAL WORK
sudo sed -i "/^#AllowUsers/ c\AllowUsers" /etc/ssh/sshd_config
sudo sed -i "/^#AllowGroups/ c\AllowGroups" /etc/ssh/sshd_config
sudo sed -i "/^#DenyUsers/ c\DenyUsers" /etc/ssh/sshd_config
sudo sed -i "/^#DenyGroups/ c\DenyGroups" /etc/ssh/sshd_config

# 5.2.19
sudo sed -i "/^#Banner/ c\Banner /etc/issue.net" /etc/ssh/sshd_config

# 5.2.20 - ANYTHING ONWARD IS UBUNTU SPECIFIC (it doesnt matter)
sudo sed -i "/^#usepam/ c\usepam yes" /etc/ssh/sshd_config

# 5.2.21
sudo sed -i "/^#AllowTcpForwarding/ c\AllowTcpForwarding no" /etc/ssh/sshd_config

# 5.2.22
sudo sed -i "/^#maxstartups/ c\maxstartups 10:30:60" /etc/ssh/sshd_config

# 5.2.23
sudo sed -i "/^#MaxSessions/ c\MaxSessions 4" /etc/ssh/sshd_config


# 5.3 pam shit
# 5.3.1
apt install libpam-pwquality
# i dont know sed, plz add

# 5.3.2
# more sed

# 5.3.3
# more sed

# 5.3.4
# more sed


# 5.4 User Acciynts and Environment
# 5.4.1.1
# sed wooo
#chage --maxdays 365 <user>

# 5.4.1.2
# sed wooo

# 5.4.1.3
# sed wooo

# 5.4.1.4
useradd -D -f 30
chage --inactive 30 <user> # loop through all users

# 5.4.1.5
# manual work

# 5.4.2 - look through cis for more details
# DO NOT RUN IN COMP IT WILL BREAK IT i think
usermod -s $(which nologin) <user>
usermod -L <user>
awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="'"$(which nologin)"'" && $7!="/bin/false") {print $1}' /etc/passwd | while read -r user; do usermod -s "$(which nologin)" "$user"; done
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' | while read -r user; do usermod -L "$user"; done

# 5.4.3
usermod -g 0 root

# 5.4.4
# sed ahahaha

# 5.4.5
# sed ahahaha

# 5.5
# manual

# 5.6
groupadd sugroup
# sed