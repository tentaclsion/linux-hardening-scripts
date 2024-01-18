#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

########################## SUPPORT FUNCTIONS #################################
SSHD_CONF=/etc/ssh/sshd_config

fetch_usr_list()
{
    egrep ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1
}

ensure_cron_file_perm()
{
    local file="$@"
    chown root:root $file
    chmod og-rwx $file
}

########################## RULE FUNCTIONS #################################


#5.1.1 Ensure cron daemon is enabled (Automated)
rule-5.1.1()
{
    print_rule_banner "Ensure cron daemon is enabled"
    systemctl --now enable cron
}

#5.1.2 Ensure permissions on /etc/crontab are configured (Automated)
rule-5.1.2()
{
    print_rule_banner "Ensure permissions on /etc/crontab are configured"
    ensure_cron_file_perm /etc/crontab
}

#5.1.3 Ensure permissions on /etc/cron.hourly are configured (Automated)
rule-5.1.3()
{
    print_rule_banner "Ensure permissions on /etc/cron.hourly are configured"
    ensure_cron_file_perm /etc/cron.hourly
}

#5.1.4 Ensure permissions on /etc/cron.daily are configured (Automated)
rule-5.1.4()
{
    print_rule_banner "Ensure permissions on /etc/cron.daily are configured"
    ensure_cron_file_perm /etc/cron.daily
}

#5.1.5 Ensure permissions on /etc/cron.weekly are configured (Automated)
rule-5.1.5()
{
    print_rule_banner "Ensure permissions on /etc/cron.weekly are configured"
    ensure_cron_file_perm /etc/cron.weekly
}

#5.1.6 Ensure permissions on /etc/cron.monthly are configured (Automated)
rule-5.1.6()
{
    print_rule_banner "Ensure permissions on /etc/cron.monthly are configured"
    ensure_cron_file_perm /etc/cron.monthly
}

#5.1.7 Ensure permissions on /etc/cron.d are configured (Automated)
rule-5.1.7()
{
    print_rule_banner "Ensure permissions on /etc/cron.d are configured"
    ensure_cron_file_perm /etc/cron.d
}

#5.1.8 Ensure at/cron is restricted to authorized users (Automated)
rule-5.1.8()
{
    print_rule_banner "Ensure at/cron is restricted to authorized users"
    rm -f /etc/cron.deny
    rm -f /etc/at.deny
    touch /etc/cron.allow
    touch /etc/at.allow
    chmod og-rwx /etc/cron.allow
    chmod og-rwx /etc/at.allow
    chown root:root /etc/cron.allow
    chown root:root /etc/at.allow
}

#5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Automated)
rule-5.2.1()
{
    print_rule_banner "Ensure permissions on /etc/ssh/sshd_config are configured"
    chown root:root /etc/ssh/sshd_config
    chmod og-rwx /etc/ssh/sshd_config
}

#5.2.2 Ensure permissions on SSH private host key files are configured (Automated)
rule-5.2.2()
{
    print_rule_banner "Ensure permissions on SSH private host key files are configured"
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;
}

#5.2.3 Ensure permissions on SSH public host key files are configured (Automated)
rule-5.2.3()
{
    print_rule_banner "Ensure permissions on SSH public host key files are configured"
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
    find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 0600 {} \;
}

#5.2.4 Ensure SSH Protocol is not set to 1 (Automated)
rule-5.2.4()
{
    print_rule_banner "Ensure SSH Protocol is not set to 1"
    sed -i -E '/^Protocol\s+/D' ${SSHD_CONF}
    echo "Protocol 2" >> ${SSHD_CONF}
}

#5.2.5 Ensure SSH LogLevel is appropriate (Automated)
rule-5.2.5()
{
    local banner="Ensure SSH LogLevel is appropriate"
    local allowed_lvls=(INFO VERBOSE)
    local log_lvl_param=$(read_usr_param ssh_log_level | tr -t [:lower:] [:upper:])

    print_rule_banner ${banner}

    echo ${allowed_lvls[@]} | grep -qw "${log_lvl_param}"
    if [ $? -eq 0 ]; then
        sed -i -E '/^LogLevel\s+/D' ${SSHD_CONF}
        echo "LogLevel ${log_lvl_param}" >> ${SSHD_CONF}
    else
        print_error_msg "Parameter log_lvl_param only allows two options: INFO or VERBOSE!"
        print_manual_req_msg ${banner}
    fi
}

#5.2.6 Ensure SSH X11 forwarding is disabled (Automated)
rule-5.2.6()
{
    print_rule_banner "Ensure SSH X11 forwarding is disabled"
    if grep -q "^X11Forwarding\b" $SSHD_CONF; then
        sed -i "s/^X11Forwarding\b.*$/X11Forwarding no/" $SSHD_CONF
    else
        echo "X11Forwarding no" >> $SSHD_CONF
    fi
}

#5.2.7 Ensure SSH MaxAuthTries is set to 4 or less (Automated)
rule-5.2.7()
{
    print_rule_banner "Ensure SSH MaxAuthTries is set to 4 or less"
    local num=$(grep -Po "(?<=^MaxAuthTries )\d+" $SSHD_CONF)
    if [ -n "$num" ]; then
        if [ $num -gt 4 ]; then
            sed -i "s/^MaxAuthTries\b.*$/MaxAuthTries 4/" $SSHD_CONF
        fi
    else
        echo "MaxAuthTries 4" >> $SSHD_CONF
    fi
}

#5.2.8 Ensure SSH IgnoreRhosts is enabled (Automated)
rule-5.2.8()
{
    print_rule_banner "Ensure SSH IgnoreRhosts is enabled"
    if grep -q "^IgnoreRhosts\b" $SSHD_CONF; then
        sed -i "s/^IgnoreRhosts\b.*$/IgnoreRhosts yes/" $SSHD_CONF
    else
        echo "IgnoreRhosts yes" >> $SSHD_CONF
    fi
}

#5.2.9 Ensure SSH HostbasedAuthentication is disabled (Automated)
rule-5.2.9()
{
    print_rule_banner "Ensure SSH HostbasedAuthentication is disabled"
    if grep -q "^HostbasedAuthentication\b" $SSHD_CONF; then
        sed -i "s/^HostbasedAuthentication\b.*$/HostbasedAuthentication no/" $SSHD_CONF
    else
        echo "HostbasedAuthentication no" >> $SSHD_CONF
    fi
}

#5.2.10 Ensure SSH root login is disabled (Automated)
rule-5.2.10()
{
    print_rule_banner "Ensure SSH root login is disabled"
    if grep -q "^PermitRootLogin\b" $SSHD_CONF; then
        sed -i "s/^PermitRootLogin\b.*$/PermitRootLogin no/" $SSHD_CONF
    else
        echo "PermitRootLogin no" >> $SSHD_CONF
    fi
}

#5.2.11 Ensure SSH PermitEmptyPasswords is disabled (Automated)
rule-5.2.11()
{
    print_rule_banner "Ensure SSH PermitEmptyPasswords is disabled"
    if grep -q "^PermitEmptyPasswords\b" $SSHD_CONF; then
        sed -i "s/^PermitEmptyPasswords\b.*$/PermitEmptyPasswords no/" $SSHD_CONF
    else
        echo "PermitEmptyPasswords no" >> $SSHD_CONF
    fi
}

#5.2.12 Ensure SSH PermitUserEnvironment is disabled (Automated)
rule-5.2.12()
{
    print_rule_banner "Ensure SSH PermitUserEnvironment is disabled"
    if grep -q "^PermitUserEnvironment\b" $SSHD_CONF; then
        sed -i "s/^PermitUserEnvironment\b.*$/PermitUserEnvironment no/" $SSHD_CONF
    else
        echo "PermitUserEnvironment no" >> $SSHD_CONF
    fi
}

#5.2.13 Ensure only strong Ciphers are used (Automated)
rule-5.2.13()
{
    local clist="aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com"
    print_rule_banner "Ensure only strong Ciphers are used"

    sed -i -E '/^Ciphers\s+/D' ${SSHD_CONF}
    echo "Ciphers ${clist}" >> ${SSHD_CONF}
}

#5.2.14 Ensure only approved MAC algorithms are used (Automated)
rule-5.2.14()
{
    local maclist="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
    print_rule_banner "Ensure only approved MAC algorithms are used"
    if grep -q "^MACs\b" $SSHD_CONF; then
        sed -i "s/^MACs\b.*$/MACs $maclist/" $SSHD_CONF
    else
        echo "MACs $maclist" >> $SSHD_CONF
    fi
}

#5.2.15 Ensure only strong Key Exchange algorithms are used (Automated)
rule-5.2.15()
{
    local kexlist="ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256"
    print_rule_banner "Ensure only strong Key Exchange algorithms are used"

    sed -i -E '/^KexAlgorithms\s+/D' ${SSHD_CONF}
    echo "KexAlgorithms ${kexlist}" >> ${SSHD_CONF}
}

#5.2.16 Ensure SSH Idle Timeout Interval is configured (Automated)
rule-5.2.16()
{
    print_rule_banner "Ensure SSH Idle Timeout Interval is configured"
    if grep -q "^ClientAliveInterval\b" $SSHD_CONF; then
        sed -i "s/^ClientAliveInterval\b.*$/ClientAliveInterval 300/" $SSHD_CONF
    else
        echo "ClientAliveInterval 300" >> $SSHD_CONF
    fi
    if grep -q "^ClientAliveCountMax\b" $SSHD_CONF; then
        sed -i "s/^ClientAliveCountMax\b.*$/ClientAliveCountMax 0/" $SSHD_CONF
    else
        echo "ClientAliveCountMax 0" >> $SSHD_CONF
    fi
}

#5.2.17 Ensure SSH LoginGraceTime is set to one minute or less (Automated)
rule-5.2.17()
{
    print_rule_banner "Ensure SSH LoginGraceTime is set to one minute or less"
    local num=$(grep -Po "(?<=^LoginGraceTime )\d+" $SSHD_CONF)
    if [ -n "$num" ]; then
        if [ $num -gt 60 ]; then
            sed -i "s/^LoginGraceTime\b.*$/LoginGraceTime 60/" $SSHD_CONF
        fi
    else
        echo "LoginGraceTime 60" >> $SSHD_CONF
    fi
}

#5.2.18 Ensure SSH access is limited (Automated)
rule-5.2.18()
{
    # Grab information from global list of parameters filled by user
    print_rule_banner "Ensure SSH access is limited"
    local params="AllowUsers AllowGroups DenyUsers DenyGroups"
    for p in $params; do
        local value=$(read_usr_param "$p")

        if [ -z "${value}" ]; then
            continue
        fi

        if grep -q "^$p\b" $SSHD_CONF; then
            sed -i "s/^$p\b.*$/$p $value/" $SSHD_CONF
        else
            echo "$p $value" >> $SSHD_CONF
        fi
    done
}

#5.2.19 Ensure SSH warning banner is configured (Automated)
rule-5.2.19()
{
    print_rule_banner "Ensure SSH warning banner is configured"
    if grep -q "^Banner\b" $SSHD_CONF; then
        sed -i "s@^Banner\b.*\$@Banner /etc/issue.net@" $SSHD_CONF
    else
        echo "Banner /etc/issue.net" >> $SSHD_CONF
    fi
}

#5.2.20 Ensure SSH PAM is enabled (Automated)
rule-5.2.20()
{
    print_rule_banner "Ensure SSH PAM is enabled"

    sed -i -E '/^UsePAM\s+/D' ${SSHD_CONF}
    echo "UsePAM yes" >> ${SSHD_CONF}
}

#5.2.21 Ensure SSH AllowTcpForwarding is disabled (Automated)
rule-5.2.21()
{
    print_rule_banner "Ensure SSH AllowTcpForwarding is disabled"

    sed -i -E '/^AllowTcpForwarding\s+/D' ${SSHD_CONF}
    echo "AllowTcpForwarding no" >> ${SSHD_CONF}
}

#5.2.22 Ensure SSH MaxStartups is configured (Automated)
rule-5.2.22()
{
    print_rule_banner "Ensure SSH MaxStartups is configured"

    sed -i -E '/^MaxStartups\s+/D' ${SSHD_CONF}
    echo "MaxStartups 10:30:60" >> ${SSHD_CONF}
}

#5.2.23 Ensure SSH MaxSessions is set to 4 or less (Automated)
rule-5.2.23()
{
    local max_sessions_param=$(read_usr_param ssh_max_sessions)
    local banner="Ensure SSH MaxSessions is set to 4 or less"
    print_rule_banner ${banner}

    if [ -n "${max_sessions_param}" ]; then
        sed -i -E '/^MaxSessions\s+/D' ${SSHD_CONF}
        echo "MaxSessions ${max_sessions_param}" >> ${SSHD_CONF}
    else
        print_manual_req_msg ${banner}
    fi
}

#5.3.1 Ensure password creation requirements are configured (Automated)
rule-5.3.1()
{
    print_rule_banner "Ensure password creation requirements are configured"
    
    # already sets /etc/pam.d/common-password with sane value
    is_installed libpam-pwquality || apt-get install libpam-pwquality -y

    # Use pam-auth-update to make sure the proper /etc/pam.d/common-password exists
    # note this is also done by the installation above
    pam-auth-update --package  pwquality

    # Sets /etc/security/pwquality.conf parameters from user defined ones
    local params="minlen minclass dcredit ucredit ocredit lcredit"
    local pwqual=/etc/security/pwquality.conf
    for p in $params; do
        local value=$(read_usr_param "$p")
        if [ -n "${value}" ]; then
            sed -i "/^$p\s*=/D" ${pwqual}
            echo "$p = $value" >> ${pwqual}
        fi
    done
}

#5.3.2 Ensure lockout for failed password attempts is configured (Automated)
rule-5.3.2()
{
    print_rule_banner "Ensure lockout for failed password attempts is configured"
    egrep -q 'pam_tally2.so.* deny=5 unlock_time=900' /etc/pam.d/common-auth
    if [ $? -gt 0 ]; then
        sed -i "1i # CIS rule 5.3.2\nauth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900" /etc/pam.d/common-auth
        sed -i -E '/account\srequisite\s+pam_deny.so/a # CIS rule 5.3.2\naccount required\t\t\tpam_tally2.so' /etc/pam.d/common-account
    fi
}

#5.3.3 Ensure password reuse is limited (Automated)
rule-5.3.3()
{
    print_rule_banner "Ensure password reuse is limited"
    local pamstr=`grep '^password required pam_pwhistory.so\b.*\bremember=' /etc/pam.d/common-password`
    if [ -z "$pamstr" ]; then
        echo "password required pam_pwhistory.so remember=5" >> /etc/pam.d/common-password
    else
        local rememb_val=`echo -n "$pamstr" | egrep -o '\bremember=[0-9]+' | cut -d '=' -f 2`
        if [ ${rememb_val} -lt 5 ]; then
            sed -E -i "s/(^password required pam_pwhistory.so\b.*\bremember=)[0-9]+/\15/" /etc/pam.d/common-password
        fi
    fi
}

#5.3.4 Ensure password hashing algorithm is SHA-512 (Automated)
rule-5.3.4()
{
    print_rule_banner "Ensure password hashing algorithm is SHA-512"
    grep '^password\s\+.*\bpam_unix\.so\b.*\bsha512\b' /etc/pam.d/common-password ||\
        sed -i 's/\(password\b.*\bpam_unix\.so\b.*\)$/\1 sha512/' /etc/pam.d/common-password
}

#5.4.1.1 Ensure password expiration is 365 days or less (Automated)
rule-5.4.1.1()
{
    local usrlist=`fetch_usr_list`
    print_rule_banner "Ensure password expiration is 365 days or less"
    sed -i -E 's/^(PASS_MAX_DAYS\s+)[0-9]+/\190/' /etc/login.defs
    for usr in $usrlist; do
        chage --maxdays 90 $usr
    done
}

#5.4.1.2 Ensure minimum days between password changes is configured (Automated)
rule-5.4.1.2()
{
    local usrlist=`fetch_usr_list`
    print_rule_banner "Ensure minimum days between password changes is configured"
    sed -i -E 's/^(PASS_MIN_DAYS\s+)[-]?[0-9]+/\11/' /etc/login.defs
    for usr in $usrlist; do
        chage --mindays 1 $usr
    done
}

#5.4.1.3 Ensure password expiration warning days is 7 or more (Automated)
rule-5.4.1.3()
{
    local usrlist=`fetch_usr_list`
    print_rule_banner "Ensure password expiration warning days is 7 or more"
    sed -i -E 's/^(PASS_WARN_AGE\s+)[-]?[0-9]+/\17/' /etc/login.defs
    for usr in $usrlist; do
        chage --warndays 7 $usr
    done
}

#5.4.1.4 Ensure inactive password lock is 30 days or less (Automated)
rule-5.4.1.4()
{
    local usrlist=`fetch_usr_list`
    print_rule_banner "Ensure inactive password lock is 30 days or less"
    useradd -D -f 30
    for usr in $usrlist; do
        chage --inactive 30 $usr
    done
}

#5.4.1.5 Ensure all users last password change date is in the past (Manual)
rule-5.4.1.5()
{
    local banner="Ensure all users last password change date is in the past"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#5.4.2 Ensure system accounts are secured (Automated)
rule-5.4.2()
{
    print_rule_banner "Ensure system accounts are secured"

    # set all system accounts to a non login shell
    awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="'"$(which nologin)"'" && $7!="/bin/false") {print $1}' /etc/passwd |\
        while read -r user; do 
            usermod -s "$(which nologin)" "$user"; 
        done
    # lock not root system accounts
    awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd |\
        xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' |\
        while read -r user; do 
            usermod -L "$user"; 
        done
}

#5.4.3 Ensure default group for the root account is GID 0 (Automated)
rule-5.4.3()
{
    print_rule_banner "Ensure default group for the root account is GID 0"
    usermod -g 0 root
}

#5.4.4 Ensure default user umask is 027 or more restrictive (Automated)
rule-5.4.4()
{
    local umask_cmd='umask 027'
    print_rule_banner "Ensure default user umask is 027 or more restrictive"
    echo "${umask_cmd}" > "$(printf ${PROFILED_PAT_PATH} ${FUNCNAME})"

    grep -q "^umask\b" $BASHRC_FILE
    if [ $? -eq 0 ]; then
        sed -E -i "s/^umask\s+.*/${umask_cmd}/" $BASHRC_FILE
    else
        echo $umask_cmd >> $BASHRC_FILE
    fi
}

#5.4.5 Ensure default user shell timeout is 900 seconds or less (Automated)
rule-5.4.5()
{
    local tmout='TMOUT=600\nreadonly TMOUT\nexport TMOUT'
    local profile_dir="/etc/profile.d"
    print_rule_banner "Ensure default user shell timeout is 900 seconds or less"

    # Remove all instances where TMOUT is set a value and is set as readonly
    sed -i -E -e '/^[^#]*\bTMOUT=[0-9]*;?/d' -e '/^[^#]*\breadonly\s+TMOUT\b;?/d' -e 's/^([^#]*)\bexport\s+TMOUT\b;?(.*)$/\1\2/g'\
        ${profile_dir}/*.sh ${PROFILE_FILE} /etc/bash.bashrc

    # Set the TMOUT in the profile.d directory
    echo -e "${tmout}" > "$(printf ${PROFILED_PAT_PATH} ${FUNCNAME})"
}

#5.5 Ensure root login is restricted to system console (Manual)
rule-5.5()
{
    local banner="Ensure root login is restricted to system console"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#5.6 Ensure access to the su command is restricted (Automated)
rule-5.6()
{
    local sugroup_name="sugroup"
    local pamfile="/etc/pam.d/su"

    print_rule_banner "Ensure access to the su command is restricted"
    egrep -q '^auth\s+required\s+pam_wheel.so\b' ${pamfile}
    if [ $? -ne 0 ]; then
        sed -E -i "/^auth\s+sufficient\s+pam_rootok.so\b/a # CIS rule 5.6\nauth required pam_wheel.so use_uid group=${sugroup_name}" ${pamfile}
    else
        egrep -q '^auth\s+required\s+pam_wheel.so\b.*\buse_uid\b' ${pamfile}
        if [ $? -ne 0 ]; then
            sed -E -i "s/^(auth\s+required\s+pam_wheel.so\b.*)/\1 use_uid/" ${pamfile}
        fi

        grep -Pq '^auth\s+required\s+pam_wheel.so\b.*\bgroup=\w+' ${pamfile}
        if [ $? -ne 0 ]; then
            sed -E -i "s/^(auth\s+required\s+pam_wheel.so\b.*)/\1 group=${sugroup_name}/" ${pamfile}
        fi
    fi

    grep -q ^${sugroup_name}:[^:]*:[^:]*:[^:]* /etc/group
    if [ $? -ne 0 ]; then
        groupadd -r ${sugroup_name}
    fi

    # group must be empty
    grp_memb=$(groupmems -g ${sugroup_name} -l)
    if [ -n "${grp_memb}" ]; then
        for memb in ${grp_memb}; do
            deluser ${memb} ${sugroup_name}
        done
    fi
}


execute_ruleset-5()
{
    local -A rulehash
    local common="5.1.1 5.1.2 5.1.3 5.1.4 5.1.5 5.1.6 5.1.7 5.1.8 5.2.1 5.2.2\
        5.2.3 5.2.4 5.2.5 5.2.7 5.2.8 5.2.9 5.2.10 5.2.11 5.2.12 5.2.13\
        5.2.14 5.2.15 5.2.16 5.2.17 5.2.18 5.2.19 5.2.20 5.2.22 5.2.23 5.3.1\
        5.3.2 5.3.3 5.3.4 5.4.1.1 5.4.1.2 5.4.1.3 5.4.1.4 5.4.1.5 5.4.2 5.4.3\
        5.4.4 5.4.5 5.5 5.6"
    rulehash[lvl1_server]="$common"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"" 5.2.6 5.2.21"
    rulehash[lvl1_workstation]="$common"" 5.2.6"
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 5.2.21"

    rulehash[custom]=$(read_rules_list 5)

    local PROFILED_FILES=$(printf ${PROFILED_PAT_PATH} 'rule-5*')
    # remove old /etc/profile.d files
    rm -f ${PROFILED_FILES}

    do_execute_rules ${rulehash[$1]}
}
