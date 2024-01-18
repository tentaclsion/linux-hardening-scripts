#!/bin/bash
#Section 4 Logging and Auditing

if [ "$EUID" -ne 0 ]
then
    echo "Run script as root"
    exit
fi
pause() {
    read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}
ubu() {
    #4.1.1.1 Ensure auditd is installed
    if [[ ! $(dpkg -s auditd | grep -i status) =~ "Status: install ok installed" ]] || [[ ! $(dpkg -s audispd-plugins | grep -i status) =~ "Status: install ok installed" ]]
    then
        apt-get install auditd audispd-plugins -y
    fi
    
    #4.1.1.2 Ensure auditd service is enabled
    if [[ ! $(systemctl is-enabled auditd) =~ "enabled" ]]
    then
        systemctl --now enable auditd
    fi
    
    #4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled
    #sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="audit=1"/g' /etc/default/grub Cant be used as it would conflict with ipv6 disable from sec 3
    echo -e 'Edit /etc/default/grub and search for the line GRUB_CMDLINE_LINUX and append "audit=1"'
    pause
    gnome-terminal -x sh -c "nano /etc/default/grub /; bash"
    update-grub

    #4.1.1.4 Ensure audit_backlog_limit is sufficient
    echo -e 'Edit /etc/default/grub and search for the line GRUB_CMDLINE_LINUX and append "audit_backlog_limit=8192"'
    pause
    gnome-terminal
    update-grub

    #4.1.2 Ensure audit log sotrage size is configured & 4.1.2.2 Ensure audit logs are not automatically deleted & 4.1.2.3 Ensure system is disabled when audit logs are full
    if [[ $(grep max_log_file /etc/audit/auditd.conf) =~ "max_log_file" ]]
    then
        echo "Change max_log_file to any value greater than or equal to 8, change max_log_file_action to keep_logs, space_left_action = email, action_mail_acct = root, admion_space_left_action = halt"
        nano /etc/audit/auditd.conf
    fi

    #4.1.3 Ensure events that modify date and time information are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then    
        echo -e "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change\n-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k timechange\n-a always,exit -F arch=b64 -S clock_settime -k time-change\n-a always,exit -F arch=b32 -S clock_settime -k time-change\n-w /etc/localtime -p wa -k time-change" | tee --append /etc/audit/rules.d/time-change.rules
    fi

    #4.1.4 Ensure events that modify user/group information are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /etc/group -p wa -k identity\n-w /etc/passwd -p wa -k identity\n-w /etc/gshadow -p wa -k identity \n-w /etc/shadow -p wa -k identity\n-w /etc/security/opasswd -p wa -k identity" | tee --append /etc/audit/rules.d/identity.rules
    fi

    #4.1.5 Ensure events that modify the system's network environment are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale\n-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale -w /etc/issue -p wa -k system-locale\n-w /etc/issue.net -p wa -k system-locale\n-w /etc/hosts -p wa -k system-locale\n-w /etc/network -p wa -k system-locale" | tee --append /etc/audit/rules.d/system-locale.rules
    fi

    #4.1.6 Ensure events that modify the system's mandatory access controls are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /etc/apparmor/ -p wa -k MAC-policy\n-w /etc/apparmor.d/ -p wa -k MAC-policy" | tee --append /etc/audit/rules.d/MAC-policy.rules
    fi

    #4.1.7 Ensure login and logout events are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /var/log/faillog -p wa -k logins\n-w /var/log/lastlog -p wa -k logins\n-w /var/log/tallylog -p wa -k logins" | tee --append /etc/audit/rules.d/logins.rules
    fi

    #4.1.8 Ensure session initiation information is collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /var/run/utmp -p wa -k session\n-w /var/log/wtmp -p wa -k logins\n-w /var/log/btmp -p wa -k logins" | tee --append /etc/audit/rules.d/session.rules
    fi

    #4.1.9 Ensure discretionary access control permission modification events are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" | tee --append /etc/audit/rules.d/perm_mod.rules
    fi

    #4.1.10 Ensure unsuccessful unauthorized file access attempts are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" | tee --append /etc/audit/rules.d/access.rules
    fi

    #4.1.11 Ensure use of privileged commands is collected
    touch /etc/audit/rules.d/privileged.rules; find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \ -k privileged" }' | tee --append /etc/audit/rules.d/privileged.rules

    #4.1.12 Ensure successful file system mounts are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts\n-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" | tee --append /etc/audit/rules.d/mounts.rules
    fi

    #4.1.13 Ensure file deletion events by users are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete\n-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" | tee --append /etc/audit/rules.d/delete.rules
    fi

    #4.1.14 Ensure changes to system administration scope (sudoers) is collected
    echo -e "-w /etc/sudoers -p wa -k scope\n-w /etc/sudoers.d/ -p wa -k scope" | tee --append /etc/audit/rules.d/scope.rules    

    #4.1.15 Ensure system administrator actions (sudolog) are collected
    echo "-w $(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//') -p wa -k actions" 
    echo -e "if a different path is outputted then change the sudo.log path"
    pause
    echo -e "-w /var/log/sudo.log -p wa -k actions" | tee --append /etc/audit/rules.d/actions.rules

    #4.1.16 Ensure kernel module loading and unloading is collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /sbin/insmod -p x -k modules\n-w /sbin/rmmod -p x -k modules\n-w /sbin/modprobe -p x -k modules\n-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" | tee --append /etc/audit/rules.d/modules.rules     
    fi

    #4.1.17 Ensure the audit configuration is immutable
    echo -e "-e 2" | tee --append /etc/audit/rules.d/99-finalize.rules

    #4.2.1.1 
    if [[ ! $(dpkg -s rsyslog|grep -i status) =~ "Status: install ok installed" ]]
    then 
        apt-get install rsyslog -y
    fi

    #4.2.1.2 Ensure rsyslog Service is enabled
    if [[ ! $(systemctl is-enabled rsyslog) =~ "enabled" ]]
    then
        systemctl --now enable rsyslog
    fi

    #4.2.1.3 Ensure logging is configured (Not Scored)

    #4.2.1.4 Ensure rsyslog default file permissions configured
    if [[ ! $(grep ^\$FileCreateMode /etc/rsyslog.conf /etc/rsyslog.d/*.conf) =~ "/etc/rsyslog.conf:$FileCreateMode 0640" ]]
    then
        sed -i 's/^$FileCreateMode .*$/$FileCreateMode 0640/g' /etc/rsyslog.conf
    fi

    #4.2.1.5 Ensure rsyslog is configured to send logs to a remote log host
    #echo -e '*.* action(type="omfwd" target="192.168.2.100" port"514" protocol="tcp" action.resumeRetryCount="100" queue.type="linkList" queue.size="1000")' | tee --append /etc/rsyslog.conf
    #echo -e '*.* action(type="omfwd" target="192.168.2.100" port"514" protocol="tcp" action.resumeRetryCount="100" queue.type="linkList" queue.size="1000")' | tee --append /etc/rsyslog.d/*.conf

    #4.2.1.6 Ensure remote rsyslog messages are only accepted on designated log hosts (Not Scored)

    #4.2.2.1 Ensure journald is configured to send logs to rsyslog
    if [[ ! $(grep -E -i "^\s*ForwardToSyslog" /etc/systemd/journald.conf) =~ "ForwardToSyslog=yes" ]]
    then    
        echo -e "ForwardToSyslog=yes" | tee --append /etc/systemd/journald.conf
    fi

    #4.2.2.2 Ensure journald is configured to copmpress large log files
    if [[ ! $(grep -E -i "^\s*Compress" /etc/systemd/journald.conf) =~ "Compress=yes" ]]
    then
        echo -e "Compress=yes" | tee --append /etc/systemd/journald.conf 
    fi

    #4.2.2.3 Ensure journald is configured to write logfiles to persistent disk
    if [[ ! $(grep -E -i "^\s*Storage" /etc/systemd/journald.conf) =~ "Storage=persistent" ]]
    then
        echo -e "Storage=persistent" | tee --append /etc/systemd/journald.conf
    fi

    #4.2.3 Ensure permissions on all logfiles are configured
    find /var/log -type f -exec chmod g-wx,o-rwx "{}" + -o -type d -exec chmod g-w,o-rwx "{}" +

    #4.3 Ensure logrotate is configured\
    
    systemctl reload auditd
    systemctl reload rsyslog
}
deb() {
    if [[ ! $(dpkg -s auditd | grep -i status) =~ "Status: install ok installed" ]] || [[ ! $(dpkg -s audispd-plugins | grep -i status) =~ "Status: install ok installed" ]]
    then
        apt-get install auditd audispd-plugins -y
    fi
    #4.1.1.1 Ensure audit log sotrage size is configured & 4.1.1.3 Ensure audit logs are not automatically deleted & 4.1.1.2 Ensure system is disabled when audit logs are full
    if [[ $(grep max_log_file /etc/audit/auditd.conf) =~ "max_log_file" ]]
    then
        echo "Change max_log_file to any value greater than or equal to 8, change max_log_file_action to keep_logs, space_left_action = email, action_mail_acct = root, admion_space_left_action = halt"
        nano /etc/audit/auditd.conf
    fi    

    #4.1.1.2 Ensure auditd service is enabled
    if [[ ! $(systemctl is-enabled auditd) =~ "enabled" ]]
    then
        systemctl --now enable auditd
    fi

    #4.1.3 Ensure auditing for processes that start prior to auditd is enabled
    #sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="audit=1"/g' /etc/default/grub Cant be used as it would conflict with ipv6 disable from sec 3
    echo -e 'Edit /etc/default/grub and search for the line GRUB_CMDLINE_LINUX and append "audit=1"'
    pause
    gnome-terminal -x sh -c "nano /etc/default/grub /; bash"
    update-grub

    #4.1.4 Ensure events that modify date and time information are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then    
        echo -e "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change\n-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k timechange\n-a always,exit -F arch=b64 -S clock_settime -k time-change\n-a always,exit -F arch=b32 -S clock_settime -k time-change\n-w /etc/localtime -p wa -k time-change" | tee --append /etc/audit/rules.d/time-change.rules
    fi

    #4.1.5 Ensure events that modify user/group information are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /etc/group -p wa -k identity\n-w /etc/passwd -p wa -k identity\n-w /etc/gshadow -p wa -k identity \n-w /etc/shadow -p wa -k identity\n-w /etc/security/opasswd -p wa -k identity" | tee --append /etc/audit/rules.d/identity.rules
    fi

    #4.1.6 Ensure events that modify the system's network environment are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale\n-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale -w /etc/issue -p wa -k system-locale\n-w /etc/issue.net -p wa -k system-locale\n-w /etc/hosts -p wa -k system-locale\n-w /etc/network -p wa -k system-locale" | tee --append /etc/audit/rules.d/system-locale.rules
    fi

    #4.1.7 Ensure events that modify the system's mandatory access controls are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /etc/apparmor/ -p wa -k MAC-policy\n-w /etc/apparmor.d/ -p wa -k MAC-policy" | tee --append /etc/audit/rules.d/MAC-policy.rules
    fi

    #4.1.8 Ensure login and logout events are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /var/log/faillog -p wa -k logins\n-w /var/log/lastlog -p wa -k logins\n-w /var/log/tallylog -p wa -k logins" | tee --append /etc/audit/rules.d/logins.rules
    fi

    #4.1.9 Ensure session initiation information is collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /var/run/utmp -p wa -k session\n-w /var/log/wtmp -p wa -k logins\n-w /var/log/btmp -p wa -k logins" | tee --append /etc/audit/rules.d/session.rules
    fi

    #4.1.10 Ensure discretionary access control permission modification events are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod\n-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" | tee --append /etc/audit/rules.d/perm_mod.rules
    fi

    #4.1.11 Ensure unsuccessful unauthorized file access attempts are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access\n-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" | tee --append /etc/audit/rules.d/access.rules
    fi

    #4.1.12 Ensure use of privileged commands is collected
    touch /etc/audit/rules.d/privileged.rules; find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 \ -k privileged" }' | tee --append /etc/audit/rules.d/privileged.rules

    #4.1.13 Ensure successful file system mounts are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts\n-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" | tee --append /etc/audit/rules.d/mounts.rules
    fi

    #4.1.14 Ensure file deletion events by users are collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete\n-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" | tee --append /etc/audit/rules.d/delete.rules
    fi

    #4.1.15 Ensure changes to system administration scope (sudoers) is collected
    echo -e "-w /etc/sudoers -p wa -k scope\n-w /etc/sudoers.d/ -p wa -k scope" | tee --append /etc/audit/rules.d/scope.rules    

    #4.1.16 Ensure system administrator actions (sudolog) are collected
    echo "-w $(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//') -p wa -k actions" 
    echo -e "if a different path is outputted then change the sudo.log path"
    pause
    echo -e "-w /var/log/sudo.log -p wa -k actions" | tee --append /etc/audit/rules.d/actions.rules

    #4.1.17 Ensure kernel module loading and unloading is collected
    if [[ $(uname -i) =~ "x86_64" ]]
    then
        echo -e "-w /sbin/insmod -p x -k modules\n-w /sbin/rmmod -p x -k modules\n-w /sbin/modprobe -p x -k modules\n-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" | tee --append /etc/audit/rules.d/modules.rules     
    fi

    #4.1.18 Ensure the audit configuration is immutable
    echo -e "-e 2" | tee --append /etc/audit/rules.d/99-finalize.rules

    if [[ ! $(dpkg -s rsyslog|grep -i status) =~ "Status: install ok installed" ]]
    then 
        apt-get install rsyslog -y
    fi

    #4.2.1.1 Ensure rsyslog Service is enabled
    if [[ ! $(systemctl is-enabled rsyslog) =~ "enabled" ]]
    then
        systemctl --now enable rsyslog
    fi

    #4.2.1.2 Ensure logging is configured (Not Scored)

    #4.2.1.3 Ensure rsyslog default file permissions configured
    if [[ ! $(grep ^\$FileCreateMode /etc/rsyslog.conf /etc/rsyslog.d/*.conf) =~ "/etc/rsyslog.conf:$FileCreateMode 0640" ]]
    then
        sed -i 's/^$FileCreateMode .*$/$FileCreateMode 0640/g' /etc/rsyslog.conf
    fi

    #4.2.1.4 Ensure rsyslog is configured to send logs to a remote log host
    # grep "^*.*[^I][^I]*@" /etc/rsyslog.conf /etc/rsyslog.d/*.conf 
    #Add to /etc/rsyslog.conf and /etc/rsyslog.d/*.conf line *.* @@loghost.example.com
    #pkill -HUP rsyslogd to reload rsyslogd configuration

    #4.2.1.5 Ensure remote rsyslog messages are only accepted on designated log hosts (Not Scored)

    if [[ ! $(dpkg -s syslog-ng|grep -i status) =~ "Status: install ok installed" ]]
    then 
        apt-get install syslog-ng -y
    fi
    
    #4.2.2.1 Ensure syslog-ng service is enabled
    if [[ ! $(systemctl is-enabled syslog-ng) =~ "enabled" ]]
    then
        update-rc.d syslog-ng enable
    fi

    #4.2.2.2 Ensure logging is configured (Not Scored)

    #4.2.2.3 Ensure syslog-ng default file permissions configured
    #grep ^options /etc/syslog-ng/syslog-ng.conf options { chain_hostnames(off); flush_lines(0); perm(0640); stats_freq(3600); threaded(yes); };
    echo -e "Edit /etc/syslog-ng/syslog-ng.conf and set perm option to 0640 or more restrictive"
    echo -e "options { chain_hostnames(off); flush_lines(0); perm(0640); stats_freq(3600); threaded(yes); };"
    pause
    gnome-terminal -x sh -c "nano /etc/syslog-ng/syslog-ng.conf /; bash"

    #4.2.2.4 Ensure syslog-ng is configured to send logs to a remote log host (Not Scored)

    #4.2.2.5 Ensure remote syslog-ng messages are only accepted on designated log hosts (Not Scored)

    #4.2.3 Ensure rsyslog or syslog-ng is installed
    if [[ ! $(dpkg -s rsyslog | grep -i status) =~ "Status: install ok installed" ]]
    then
        apt-get install rsyslog -y
    fi    
    if [[ ! $(dpkg -s syslog-ng | grep -i status) =~ "Status: install ok installed" ]]
    then
        apt-get install syslog-ng -y
    fi    

    #4.2.4 Ensure permissions on all logfiles are configured
    chmod -R g-wx,o-rwx /var/log/*

    #4.3 Ensure logrotate is configured (Not Scored)
}
printf "<*> Is this Ubuntu 18.04 or Debian 9 <U|D>:/n"
read -p "" -n 1 -r
if [[ $REPLY =~ ^[Uu]$ ]]
then
    ubu
elif [[ $REPLY =~ ^[Dd]$ ]]
then
    deb
fi