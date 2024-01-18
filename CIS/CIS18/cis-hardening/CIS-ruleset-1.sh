#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

# Global vars

########################## SUPPORT FUNCTIONS #################################

# Add new mount options into /etc/fstab file
# 1st argument is the mountpoint to be modified
# 2nd argument is the list of options
add_fstab_opts()
{
    if [ $# -lt 2 ]; then
        return 1
    fi

    local mpoint=$1
    shift
    local opt_list=$@

    result=$(grep $mpoint /etc/fstab)
    # Only modify if the line exists. Otherwise, do nothing
    if [ -z "$result" ]; then
        return 1
    fi
    # Loop over options adding if needed
    for opt in $opt_list; do
        # see if it has opt if not, add it.
        if [[ $result != *"$opt"* ]]; then
            awk '$2 == "'$mpoint'" {$4=$4",'$opt'"}1' /etc/fstab > /etc/fstab.CIS
            mv /etc/fstab.CIS /etc/fstab
            mount -o remount,$opt $mpoint
        fi
    done
}

# generic function to ensure mount option on mount point
# 1st argument is mountpoint, second is option
ensure_opt_mountpoint()
{
    local mpoint=$1
    local mopt=$2

    print_rule_banner "Ensure $mopt option set on $mpoint partition"
    result=$(grep $mpoint /etc/fstab)
    if [ -n "$result" ]; then
        add_fstab_opts $mpoint $mopt
    else
        echo "No $mpoint partition present"
    fi
}

# This removes all grub lines related to the bootloader password rule
# script
remove_grub_password_lines()
{
    local file="$1"

    if [ -z "${file}" ]; then
        return
    fi

    local num_lines_file=$(($(wc -l ${file} | cut -d' ' -f1) + 1))
    local termtor=""
    local cat_line_num=0

    # We grab the lines in the reverse order so we can remove them and not have
    # to regenerate the list.
    for pw_line_num in $(egrep -n "^password_pbkdf2 \w+ grub\.pbkdf2\." "${file}" | cut -d: -f1 | tac); do
        termtor=""
        # scan line by line up until you find a cat <<*TERMINATOR* pattern (or get to line 1)
        cat_line_num=$((pw_line_num-1))
        while [ ${cat_line_num} -gt 0 ]; do
            termtor=$(sed -n "${cat_line_num}"p ${file} | grep -Po "(?<=^cat <<)\s*[^ ]+$" | sed -E 's/^\s+//')
            if [ -n "${termtor}" ]; then
                break
            fi
            cat_line_num=$((cat_line_num-1))
        done

        # if no cat id found, we just leave without deleting anything. This format is incorrect.
        if [ -z "${termtor}" ]; then
            return
        fi

        # now scan line by line down until you find a line containing only the *TERMINATOR* (or get to the last line)
        local term_line_num=$((pw_line_num+1))
        while [ ${term_line_num} -le ${num_lines_file} ]; do
            if [ $(sed -n "${term_line_num}"p ${file}) == "${termtor}" ]; then
                break
            fi
            term_line_num=$((term_line_num+1))
        done

        # If no terminator found at the end, we just leave without deleting anything. This format is incorrect.
        if [ ${term_line_num} -gt ${num_lines_file} ]; then
            return
        fi

        # Otherwise we found the first line and the last line to be deleted, so we delete them.
        sed -i "${cat_line_num}","${term_line_num}"d ${file}
    done
}

########################## RULE FUNCTIONS #################################

# 1.1.1.1 Ensure mounting of cramfs filesytems is disabled (Automated)
rule-1.1.1.1()
{
    print_rule_banner "Ensure mounting of cramfs filesytems is disabled"
    disable_mod cramfs
}

# 1.1.1.2 Ensure mounting of freevxfs filesytems is disabled (Automated)
rule-1.1.1.2()
{
    print_rule_banner "Ensure mounting of freevxfs filesytems is disabled"
    disable_mod freevxfs
}

# 1.1.1.3 Ensure mounting of jffs2 filesytems is disabled (Automated)
rule-1.1.1.3()
{
    print_rule_banner "Ensure mounting of jffs2 filesytems is disabled"
    disable_mod jffs2
}

# 1.1.1.4 Ensure mounting of hfs filesytems is disabled (Automated)
rule-1.1.1.4()
{
    print_rule_banner "Ensure mounting of hfs filesytems is disabled"
    disable_mod hfs
}

# 1.1.1.5 Ensure mounting of hfsplus filesytems is disabled (Automated)
rule-1.1.1.5()
{
    print_rule_banner "Ensure mounting of hfsplus filesytems is disabled"
    disable_mod hfsplus
}

# 1.1.1.6 Ensure mounting of squashfs filesytems is disabled
rule-1.1.1.6()
{
    print_rule_banner "Ensure mounting of squashfs filesytems is disabled"
    disable_mod squashfs
}

# 1.1.1.7 Ensure mounting of udf filesytems is disabled (Automated)
rule-1.1.1.7()
{
    print_rule_banner "Ensure mounting of udf filesytems is disabled"
    disable_mod udf
}

# 1.1.1.8 Ensure mounting of FAT filesystems is limited (Manual)
rule-1.1.1.8()
{
    local banner="Ensure mounting of FAT filesystems is limited"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.2 Ensure /tmp is configured (Manual | Benchmark Automated)
rule-1.1.2()
{
    local banner="Ensure /tmp is configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.3 Ensure nodev option set on /tmp partition (Automated)
rule-1.1.3()
{
    ensure_opt_mountpoint /tmp nodev
}

# 1.1.4 Ensure nosuid option set on /tmp partition (Automated)
rule-1.1.4()
{
    ensure_opt_mountpoint /tmp nosuid
}

# 1.1.5 Ensure noexec option set on /tmp partition (Automated)
rule-1.1.5()
{
    ensure_opt_mountpoint /tmp noexec
}

# 1.1.6 Ensure separate partition exists for /var (Manual | Benchmark Automated)
rule-1.1.6()
{
    local banner="Ensure separate partition exists for /var"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.7 Ensure separate partition exists for /var/tmp (Manual | Benchmark Automated)
rule-1.1.7()
{
    local banner="Ensure separate partition exists for /var/tmp"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.8 Ensure nodev option set on /var/tmp partition (Automated)
rule-1.1.8()
{
    ensure_opt_mountpoint /var/tmp nodev
}

# 1.1.9 Ensure nosuid option set on /var/tmp partition (Automated)
rule-1.1.9()
{
    ensure_opt_mountpoint /var/tmp nosuid
}

# 1.1.10 Ensure noexec option set on /var/tmp partition (Automated)
rule-1.1.10()
{
    ensure_opt_mountpoint /var/tmp noexec 
}

# 1.1.11 Ensure separate partition exists for /var/log (Manual | Benchmark Automated)
rule-1.1.11()
{
    local banner="Ensure separate partition exists for /var/log"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.12 Ensure separate partition exists for /var/log/audit (Manual | Benchmark Automated)
rule-1.1.12()
{
    local banner="Ensure separate partition exists for /var/log/audit"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.13 Ensure separate partition exists for /home (Manual | Benchmark Automated)
rule-1.1.13()
{
    local banner="Ensure separate partition exists for /home"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.14 Ensure nodev option set on /home partition (Automated)
rule-1.1.14()
{
    # If there is a /home partition, make sure nodev option is set
    # If not, DO NOT change anything.
    ensure_opt_mountpoint /home nodev
}

# 1.1.15 Ensure nodev option set on /dev/shm partition (Automated)
rule-1.1.15()
{
    print_rule_banner "Ensure nodev option set on /dev/shm partition"

    # Rule only is applied if /dev/shm exists
    if [ ! -e /dev/shm ]; then
        echo "/dev/shm device file does not exist. Skipping rule."
        return
    fi

    result=$(grep /dev/shm /etc/fstab)
    if [ -n "$result" ]; then
        add_fstab_opts /dev/shm nodev
    else
        echo "tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab
        mount -o remount,nosuid,nodev,noexec /dev/shm
    fi
}

#1.1.16 Ensure nosuid option set on /dev/shm partition (Automated)
rule-1.1.16()
{
    print_rule_banner "Ensure nosuid option set on /dev/shm partition"

    # Rule only is applied if /dev/shm exists
    if [ ! -e /dev/shm ]; then
        echo "/dev/shm device file does not exist. Skipping rule."
        return
    fi

    result=$(grep /dev/shm /etc/fstab)
    if [ -n "$result" ]; then
        add_fstab_opts /dev/shm nosuid
    else
        echo "tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab
        mount -o remount,nosuid,nodev,noexec /dev/shm
    fi
}

#1.1.17 Ensure noexec option set on /dev/shm partition (Automated)
rule-1.1.17()
{
    print_rule_banner "Ensure noexec option set on /dev/shm partition"

    # Rule only is applied if /dev/shm exists
    if [ ! -e /dev/shm ]; then
        echo "/dev/shm device file does not exist. Skipping rule."
        return
    fi

    result=$(grep /dev/shm /etc/fstab)
    if [ -n "$result" ]; then
        add_fstab_opts /dev/shm noexec
    else
        echo "tmpfs /dev/shm tmpfs rw,nosuid,nodev,noexec 0 0" >> /etc/fstab
        mount -o remount,nosuid,nodev,noexec /dev/shm
    fi
}

#1.1.18-1.1.20 are manual on benchmark (removable media related)
# 1.1.18 Ensure nodev option set on removable media partitions (Manual)
rule-1.1.18()
{
    local banner="Ensure nodev option set on removable media partitions"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.19 Ensure nosuid option set on removable media partitions (Manual)
rule-1.1.19()
{
    local banner="Ensure nosuid option set on removable media partitions"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.1.20 Ensure noexec option set on removable media partitions (Manual)
rule-1.1.20()
{
    local banner="Ensure noexec option set on removable media partitions"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#1.1.21 Ensure sticky bit on world-writable directories (Automated)
rule-1.1.21()
{
    print_rule_banner "Ensure sticky bit on world-writable directories"
    df --local -P | awk '{if (NR!=1) print $6}' |\
        xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null |\
        xargs -I '{}' chmod a+t '{}'
}

#1.1.22 Disable Automounting (Automated)
rule-1.1.22()
{
    print_rule_banner "Disable Automounting"
    systemctl --now disable autofs.service
}

#1.1.23 Disable USB Storage (Automated)
rule-1.1.23()
{
    print_rule_banner "Disable USB Storage"
    disable_mod usb-storage
}

# Rules 1.2.1 and 1.2.2 are manual on benchmark
# 1.2.1 Ensure package manager repositories are configured (Manual)
rule-1.2.1()
{
    local banner="Ensure package manager repositories are configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.2.2 Ensure GPG keys are configured (Manual)
rule-1.2.2()
{
    local banner="Ensure GPG keys are configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#1.3.1 Ensure sudo is installed (Automated)
rule-1.3.1()
{
    # We only make sure sudo is installed, not sudo-ldap
    print_rule_banner "Ensure sudo is installed"
    apt-get install sudo -y
}

#1.3.2 Ensure sudo commands use pty
rule-1.3.2()
{
    # Cannot add names with '.' to sudoers.d dir
    local sudo_conf="$(printf ${SUDO_PAT_PATH} ${FUNCNAME//\./_})"
    print_rule_banner "Ensure sudo commands use pty"
    echo "Defaults use_pty" > ${sudo_conf}
    # files in sudoers.d must have 0440 permission
    chmod 0440 ${sudo_conf}
}

#1.3.3 Ensure sudo log file exists (Automated)
rule-1.3.3()
{
    # Cannot add names with '.' to sudoers.d dir
    local sudo_conf="$(printf ${SUDO_PAT_PATH} ${FUNCNAME//\./_})"
    local banner="Ensure sudo log file exists"
    local sudolog=$(read_usr_param sudo_log)

    print_rule_banner ${banner}

    # If sudo_log parameter is empty, requests manual mode
    if [ -z "${sudolog}" ]; then
        print_manual_req_msg ${banner}
        return
    fi

    echo "Defaults logfile=${sudolog}" > ${sudo_conf}
    # files in sudoers.d must have 0440 permission
    chmod 0440 ${sudo_conf}
}

#1.4.1 Ensure AIDE is installed (Automated)
rule-1.4.1()
{
    print_rule_banner "Ensure AIDE is installed"
    echo "****** Note this rule installs postfix as well, which requires additional MANUAL configuration ******"
    debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"
    apt-get install -y postfix
    apt-get install aide aide-common -y
    aideinit -y -f
}

#1.4.2 Ensure filesystem integrity is regularly checked (Automated)
rule-1.4.2()
{
    local ctab_line="0 5 * * * root /usr/bin/aide.wrapper --config /etc/aide/aide.conf --check"
    print_rule_banner "Ensure filesystem integrity is regularly checked"

    # AiDE usually adds its own cron jobs to /etc/cron.daily. If script is there, this rule is
    # compliant.
    egrep -q '^(/usr/bin/)?aide\.wrapper\s+' /etc/cron.*/* && return

    if ! grep -q "$ctab_line" /etc/crontab; then
        echo -e "# Line added by CIS hardening scripts\n""$ctab_line" >> /etc/crontab
        echo "****** /etc/crontab was changed to enable AIDE periodical checks ******"
    fi
}

#1.5.1 Ensure permissions on bootloader config are configured (Automated)
rule-1.5.1()
{
    local cfg="/boot/grub/grub.cfg"

    print_rule_banner "Ensure permissions on bootloader config are configured"
    chown root:root $cfg
    chmod og-rwx $cfg
}

#1.5.2 Ensure bootloader password is set (Automated)
rule-1.5.2()
{
    local arch=$(uname -m)
    local banner="Ensure bootloader password is set"
    print_rule_banner ${banner}

    if [[ "${arch}" == 's390x' ]]; then
        echo "zipl does not support bootloader password"
        return
    fi

    local pbkdf2_hash=$(read_usr_param grub_hash)
    local user=$(read_usr_param grub_user)
    local hdrconf=/etc/grub.d/00_header
    local linuxconf=/etc/grub.d/10_linux
   
    if [ -z "${user}" ] || [ -z "${pbkdf2_hash}" ]; then
        print_manual_req_msg ${banner}
        return
    fi

    # --unrestricted flag to allow boot without password
    # Note this still protects against unauthorized entry editing
    egrep '^CLASS=".* --unrestricted( .*)?"' ${linuxconf}
    if [ $? -ne 0 ]; then
        sed -i -E 's/^(CLASS="[^"]*)/\1 --unrestricted/' ${linuxconf}
    fi

    remove_grub_password_lines ${hdrconf}

    # Check if line to append is empty. Otherwise, add to next line.
    if [ -n "$(tail -n1 ${hdrconf})" ]; then
        echo "" >> ${hdrconf}
    fi

    echo "cat <<CIS-${FUNCNAME}" >> ${hdrconf}
    echo "set superusers=\"${user}\"" >> ${hdrconf}
    echo "password_pbkdf2 ${user} ${pbkdf2_hash}" >> ${hdrconf}
    echo -n "CIS-${FUNCNAME}" >> ${hdrconf}

    do_update_grub
}

#1.5.3 Ensure authentication required for single user mode (Automated)
rule-1.5.3()
{
    local root_hash=$(read_usr_param root_hash)
    local banner="Ensure authentication required for single user mode"

    print_rule_banner ${banner}

    if [ -z "${root_hash}" ]; then
        print_manual_req_msg ${banner}
        return
    fi

    sed -E -i "s@^root:[^:]*@root:${root_hash}@" /etc/shadow
}

#1.5.4 Ensure interactive boot is not enabled (Manual)
rule-1.5.4()
{
    local banner="Ensure interactive boot is not enabled"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# 1.6.1 Ensure XD/NX support is enabled (Manual | Benchmark Automated)
rule-1.6.1()
{
    local banner="Ensure XD/NX support is enabled"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#1.6.2 Ensure address space layout randomization (ASLR) is enabled (Automated)
rule-1.6.2()
{
    print_rule_banner "Ensure address space layout randomization (ASLR) is enabled"
    echo "kernel.randomize_va_space=2" > $(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})
    sysctl -w kernel.randomize_va_space=2
}

# 1.6.3 Ensure prelink is disabled
rule-1.6.3()
{
    print_rule_banner "Ensure prelink is disabled"
    prelink -ua 2>/dev/null
    apt-get purge prelink 2>/dev/null
}

#1.6.4 Ensure core dumps are restricted (Automated)
rule-1.6.4()
{
    local sysdconf="/etc/systemd/coredump.conf"
    print_rule_banner "Ensure core dumps are restricted"

    echo "* hard core 0" > $(printf ${LIMITSD_PAT_PATH} ${FUNCNAME})

    echo 'fs.suid_dumpable=0' > $(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})

    # additional steps if systemd-coredump is installed
    is_installed systemd-coredump
    if [ $? -eq 0 ]; then
        sed -i "/^Storage=/D" ${sysdconf}
        echo "Storage=none" >> ${sysdconf}

        sed -i "/^ProcessSizeMax=/D" ${sysdconf}
        echo "ProcessSizeMax=0" >> ${sysdconf}

        systemctl daemon-reload
    fi

    # Disable apport to prevent it from setting
    # suid_dumpable flag
    sed -i "s/^enabled=1/enabled=0/" /etc/default/apport

    sysctl -w fs.suid_dumpable=0
}

#1.7.1.1 Ensure AppArmor is installed (Automated)
rule-1.7.1.1()
{
    print_rule_banner "Ensure AppArmor is installed"
    apt-get install apparmor apparmor-utils -y
}

#1.7.1.2 Ensure AppArmor is enabled in the bootloadedr configuration (Automated)
rule-1.7.1.2()
{
    print_rule_banner "Ensure AppArmor is enabled in the bootloadedr configuration"
    add_kernel_boot_param apparmor 1
    add_kernel_boot_param security apparmor
    do_update_grub
}

#1.7.1.3 Ensure all AppArmor Profiles are in enforce or complain mode (Automated)
rule-1.7.1.3()
{
    local lvl1_aa_enforce=$(read_usr_param lvl1_apparmor_enforce)

    print_rule_banner "Ensure all AppArmor Profiles are in enforce or complain mode"

    # apparmor and apparmor-utils must be installed to be compliant to this rule.
    is_installed apparmor || apt-get install apparmor -y
    is_installed apparmor-utils || apt-get install apparmor-utils -y

    if [ -z "${lvl1_aa_enforce}" ] || [ "${lvl1_aa_enforce}" != true ]; then
        aa-complain /etc/apparmor.d/*
    else
        aa-enforce /etc/apparmor.d/*
    fi
}

#1.7.1.4 Ensure all AppArmor profiles are enforcing (Automated)
rule-1.7.1.4()
{
    print_rule_banner "Ensure all AppArmor Profiles are enforcing"

    # apparmor and apparmor-utils must be installed to be compliant to this rule.
    is_installed apparmor || apt-get install apparmor -y
    is_installed apparmor-utils || apt-get install apparmor-utils -y

    aa-enforce /etc/apparmor.d/*
}

# 1.8.1.1 Ensure message of the day is configured properly (Automated)
rule-1.8.1.1()
{
    print_rule_banner "Ensure message of the day is configured properly"
    sed -i -E 's/(\\s|\\v|\\m|\\r)//g' /etc/motd
}

# 1.8.1.2 Ensure local login warning banner is configured properly (Automated)
rule-1.8.1.2()
{
    print_rule_banner "Ensure local login warning banner is configured properly"
    echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
}

# 1.8.1.3 Ensure remote login warning banner is configured properly (Automated)
rule-1.8.1.3()
{
    print_rule_banner "Ensure remote login warning banner is configured properly"
    echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net
}

# 1.8.1.4 Ensure permissions on /etc/motd are configured (Automated)
rule-1.8.1.4()
{
    print_rule_banner "Ensure permissions on /etc/motd are configured"
    chown root:root /etc/motd
    chmod 644 /etc/motd
}

# 1.8.1.5 Ensure permissions on /etc/issue are configured (Automated)
rule-1.8.1.5()
{
    print_rule_banner "Ensure permissions on /etc/issue are configured"
    chown root:root /etc/issue
    chmod 644 /etc/issue
}

# 1.8.1.6 Ensure permissions on /etc/issue.net are configured (Automated)
rule-1.8.1.6()
{
    print_rule_banner "Ensure permissions on /etc/issue.net are configured"
    chown root:root /etc/issue.net
    chmod 644 /etc/issue.net
}

# 1.8.2 Ensure GDM login banner is configured (Automated)
rule-1.8.2()
{
    local conftext="banner-message-enable=true\nbanner-message-text='Authorized uses only. All activity may be monitored and reported.'"
    local conffile="/etc/gdm3/greeter.dconf-defaults"
    print_rule_banner "Ensure GDM login banner is configured"
    sed -i '/banner-message-enable=/d;/banner-message-text=/d' ${conffile}

    grep -q '^\[org/gnome/login-screen\]' ${conffile} 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "\n[org/gnome/login-screen]" >> ${conffile}
    fi

    sed -i "/^\[org\/gnome\/login-screen\]/a""${conftext}" ${conffile}
}

# 1.9 Ensure updates, patches, and additional security software are installed (Manual)
rule-1.9()
{
    print_rule_banner "Ensure updates, patches, and additional security software are installed"
    echo "Ensure updates, patches, and additional security software are installed - requires manual configuration!"
}

# Execute ruleset, based on level and profile provided.
# Argument 1 the chosen profile
execute_ruleset-1()
{
    local -A rulehash
    local common="1.1.1.1 1.1.1.2 1.1.1.3 1.1.1.4 1.1.1.5 1.1.1.6 1.1.1.7\
        1.1.2 1.1.3 1.1.4 1.1.5 1.1.8 1.1.9 1.1.10 1.1.14 1.1.15\
        1.1.16 1.1.17 1.1.18 1.1.19 1.1.20 1.1.21 1.2.1 1.2.2 1.3.1 1.3.2\
        1.3.3 1.4.1 1.4.2 1.5.1 1.5.2 1.5.3 1.5.4 1.6.1 1.6.2 1.6.3 1.6.4\
        1.7.1.1 1.7.1.2 1.7.1.3 1.8.1.1 1.8.1.2 1.8.1.3 1.8.1.4 1.8.1.5\
        1.8.1.6 1.8.2 1.9"
    rulehash[lvl1_server]=$common" 1.1.22 1.1.23"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"" 1.1.1.8 1.1.6 1.1.7\
        1.1.11 1.1.12 1.1.13 1.7.1.4"
    rulehash[lvl1_workstation]=$common
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 1.1.1.8 1.1.6\
        1.1.7 1.1.11 1.1.12 1.1.13 1.1.22 1.1.23 1.7.1.4"

    rulehash[custom]=$(read_rules_list 1)

    local SYSCTLD_FILES=$(printf ${SYSCTLD_PAT_PATH} 'rule-1*')
    local LIMITSD_FILES=$(printf ${LIMITSD_PAT_PATH} 'rule-1*')

    # remove old /etc/security/limits.d and /etc/sysctl.d files
    rm -f ${LIMITSD_FILES} ${SYSCTLD_FILES}

    # remove old modprobe conf file
    rm -f $(printf ${MODPROB_PAT_PATH} 'rule-1*')

    do_execute_rules ${rulehash[$1]}
}
