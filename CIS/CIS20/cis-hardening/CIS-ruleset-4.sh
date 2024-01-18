#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

########################## SUPPORT FUNCTIONS #################################
AUDIT_CONF='/etc/audit/auditd.conf' # Config file of auditd server
AUDIT_RULE_DIR='/etc/audit/rules.d' # Target dir of audit rules
AUDIT_PAT_NAME="Canonical_Ubuntu_CIS_%s.rules"
SRC_DIR='./audit_rules' # Source dir of audit rules
SYSLOG_PAT_PATH='/etc/rsyslog.d/99-Canonical_Ubuntu_CIS_%s.conf'
JOURNALD_CONF=/etc/systemd/journald.conf
LOGROTATE_CONF=/etc/logrotate.conf

# Return the path of the syslog conf file, based upon the rule function
# executing it.
# This must be executed inside a <rule-NUM> function type!
syslog_conf_path()
{
    printf ${SYSLOG_PAT_PATH} $(get_rule_tag)
}

install_auditd()
{
    apt-get install auditd -y
}

install_rsyslog()
{
    apt-get install rsyslog -y
}

reload_svc_conf()
{
    systemctl kill auditd -s SIGHUP # Forces configuration reload
}

# Print banner based on audit file comment
print_audit_banner()
{
    local aufpath="$@"
    local text=$(sed -n '{ 6s/^# // p }' ${aufpath})
    print_rule_banner "${text}"
}

# Generate audit file for rule 4.1.11 from list of privileged files
generate_audit_privilege()
{
    echo "#"
    echo "# Copyright 2019 Canonical Limited. All rights reserved."
    echo "#"
    echo "#--------------------------------------------------------"
    echo
    echo "# Ensure use of privileged commands is collected"
    df --local -P | awk {'if (NR!=1) print $6'} |\
     xargs -I '{}' find '{}' -xdev \( -perm -4000 -o -perm -2000 \) -type f |\
     awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" }'
}

# Copy audit rules file from source dir to target (usually /etc/audit/rules.d) dir
# This function must be used inside the "rule-<rulenum>" functions
copy_audit_rule()
{
    cp -f ${SRC_DIR}/$(printf ${AUDIT_PAT_NAME} $(get_rule_tag)) ${AUDIT_RULE_DIR}
}

########################## RULE FUNCTIONS #################################

#4.1.1.1 Ensure auditd is installed (Automated)
rule-4.1.1.1()
{
    print_rule_banner "Ensure auditd is installed"
    # Make sure auditd and auditspd-plugins are installed
    is_installed auditd || apt-get install -y auditd
    is_installed audispd-plugins || apt-get install -y audispd-plugins
}

#4.1.1.2 Ensure auditd service is enabled (Automated)
rule-4.1.1.2()
{
    print_rule_banner "Ensure auditd service is enabled"
    systemctl --now enable auditd
}

#4.1.1.3 Ensure auditing for processes that start prior to auditd is enabled (Automated)
rule-4.1.1.3()
{
    print_rule_banner "Ensure auditing for processes that start prior to auditd is enabled"
    add_kernel_boot_param audit 1
    do_update_grub
}

#4.1.1.4 Ensure audit_backlog_limit is sufficient (Automated)
rule-4.1.1.4()
{
    print_rule_banner "Ensure audit_backlog_limit is sufficient"
    add_kernel_boot_param audit_backlog_limit 8192
    do_update_grub
}

#4.1.2.1 Ensure audit log storage size is configured (Automated)
rule-4.1.2.1()
{
    print_rule_banner "Ensure audit log storage size is configured"
    local value=$(read_usr_param "max_log_file")
    if [ -n "$value" ]; then
        sed -i "/^max_log_file\s*=/D" ${AUDIT_CONF}
        echo "max_log_file = ${value}" >> ${AUDIT_CONF}
    else
        echo "Error on ${FUNCNAME}: Parameter max_log_file is null." >&2
    fi
    reload_svc_conf
}

#4.1.2.2 Ensure audit logs are not automatically deleted (Automated)
rule-4.1.2.2()
{
    print_rule_banner "Ensure audit logs are not automatically deleted"
    sed -i "/^max_log_file_action\s*=/D" ${AUDIT_CONF}
    echo "max_log_file_action = keep_logs" >> ${AUDIT_CONF}
    reload_svc_conf
}

#4.1.2.3 Ensure system is disabled when audit logs are full (Automated)
rule-4.1.2.3()
{
    print_rule_banner "Ensure system is disabled when audit logs are full"
    sed -i "/^space_left_action\s*=/D" ${AUDIT_CONF}
    sed -i "/^action_mail_acct\s*=/D" ${AUDIT_CONF}
    sed -i "/^admin_space_left_action\s*=/D" ${AUDIT_CONF}
    echo "space_left_action = email" >> ${AUDIT_CONF}
    echo "action_mail_acct = root" >> ${AUDIT_CONF}
    echo "admin_space_left_action = halt" >> ${AUDIT_CONF}
    reload_svc_conf
}

#4.1.3 Ensure events that modify date and time information are collected (Automated)
rule-4.1.3()
{
    print_rule_banner "Ensure events that modify date and time information are collected"
    copy_audit_rule
}

#4.1.4 Ensure events that modify user/group information are collected (Automated)
rule-4.1.4()
{
    print_rule_banner "Ensure events that modify user/group information are collected"
    copy_audit_rule
}

#4.1.5 Ensure events that modify the system's network environment are collected (Automated)
rule-4.1.5()
{
    print_rule_banner "Ensure events that modify the system's network environment are collected"
    copy_audit_rule
}

#4.1.6 Ensure events that modify the system's Mandatory Access Controls are collected (Automated)
rule-4.1.6()
{
    print_rule_banner "Ensure events that modify the system's Mandatory Access Controls are collected"
    copy_audit_rule
}

#4.1.7 Ensure login and logout events are collected (Automated)
rule-4.1.7()
{
    print_rule_banner "Ensure login and logout events are collected"
    copy_audit_rule
}

#4.1.8 Ensure session initiation information is collected (Automated)
rule-4.1.8()
{
    print_rule_banner "Ensure session initiation information is collected"
    copy_audit_rule
}

#4.1.9 Ensure discretionary access control permission modification events are collected (Automated)
rule-4.1.9()
{
    print_rule_banner "Ensure discretionary access control permission modification events are collected"
    copy_audit_rule
}

#4.1.10 Ensure unsuccessful unauthorized file access attempts are collected (Automated)
rule-4.1.10()
{
    print_rule_banner "Ensure unsuccessful unauthorized file access attempts are collected"
    copy_audit_rule
}

#4.1.11 Ensure use of privileged commands is collected (Automated)
rule-4.1.11()
{
    print_rule_banner "Ensure use of privileged commands is collected"
    generate_audit_privilege > ${AUDIT_RULE_DIR}/$(printf ${AUDIT_PAT_NAME} ${FUNCNAME})
}

#4.1.12 Ensure successful file system mounts are collected (Automated)
rule-4.1.12()
{
    print_rule_banner "Ensure successful file system mounts are collected"
    copy_audit_rule
}

#4.1.13 Ensure file deletion events by users are collected (Automated)
rule-4.1.13()
{
    print_rule_banner "Ensure file deletion events by users are collected"
    copy_audit_rule
}

#4.1.14 Ensure changes to system administration scope (sudoers) is collected (Automated)
rule-4.1.14()
{
    print_rule_banner "Ensure changes to system administration scope (sudoers) is collected"
    copy_audit_rule
}

#4.1.15 Ensure system administrator command executions (sudo) are collected (Automated)
rule-4.1.15()
{
    print_rule_banner "Ensure system administrator command executions (sudo) are collected"
    copy_audit_rule
}

#4.1.16 Ensure kernel module loading and unloading is collected (Automated)
rule-4.1.16()
{
    print_rule_banner "Ensure kernel module loading and unloading is collected"
    copy_audit_rule
}

#4.1.17 Ensure the audit configuration is immutable (Automated)
rule-4.1.17()
{
    print_rule_banner "Ensure the audit configuration is immutable"
    copy_audit_rule
}

#4.2.1.1 Ensure rsyslog is installed (Automated)
rule-4.2.1.1()
{
    print_rule_banner "Ensure rsyslog is installed"
    is_installed rsyslog || apt-get install rsyslog -y
}

#4.2.1.2 Ensure rsyslog Service is enabled (Automated)
rule-4.2.1.2()
{
    print_rule_banner "Ensure rsyslog Service is enabled"
    systemctl --now enable rsyslog
}

#4.2.1.3 Ensure logging is configured (Manual)
rule-4.2.1.3()
{
    local banner="Ensure logging is configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#4.2.1.4 Ensure rsyslog default file permissions configured (Automated)
rule-4.2.1.4()
{
    print_rule_banner "Ensure rsyslog default file permissions configured"
    sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/*
    echo '$FileCreateMode 0640' > $(syslog_conf_path)
}

#4.2.1.5 Ensure rsyslog is configured to send logs to a remote log host (Automated)
rule-4.2.1.5()
{
    local banner="Ensure rsyslog is configured to send logs to a remote log host"
    local remote_host=`read_usr_param remote_log_server`

    print_rule_banner ${banner}
    if [ -z "${remote_host}" ]; then
        print_manual_req_msg ${banner}
    else
        echo "*.* @@${remote_host}" > $(syslog_conf_path)
    fi
}

#4.2.1.6 Ensure remote rsyslog messages are only accepted on designated log hosts. (Manual)
rule-4.2.1.6()
{
    local banner="Ensure remote rsyslog messages are only accepted on designated log hosts"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#4.2.2.1 Ensure journald is configured to send logs to rsyslog (Automated)
rule-4.2.2.1()
{
    print_rule_banner "Ensure journald is configured to send logs to rsyslog"
    sed -i '/^\s*ForwardToSyslog=/D' ${JOURNALD_CONF}
    echo 'ForwardToSyslog=yes' >> ${JOURNALD_CONF}
}

#4.2.2.2 Ensure journald is configured to compress large log files (Automated)
rule-4.2.2.2()
{
    print_rule_banner "Ensure journald is configured to compress large log files"
    sed -i '/^\s*Compress=/D' ${JOURNALD_CONF}
    echo 'Compress=yes' >> ${JOURNALD_CONF}
}

#4.2.2.3 Ensure journald is configured to write logfiles to persistent disk (Automated)
rule-4.2.2.3()
{
    print_rule_banner "Ensure journald is configured to write logfiles to persistent disk"
    sed -i '/^\s*Storage=/D' ${JOURNALD_CONF}
    echo 'Storage=persistent' >> ${JOURNALD_CONF}
}

#4.2.3 Ensure permissions on all logfiles are configured (Automated)
rule-4.2.3()
{
    local banner="Ensure permissions on all logfiles are configured"
    print_rule_banner ${banner}
    # Since it doesn't work properly due to dpkg.log permissions, we decided it isn't worth
    # the maintenance effort.
    print_manual_req_msg ${banner}

}

#4.3 Ensure logrotate is configured (Manual)
rule-4.3()
{
    local banner="Ensure logrotate is configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#4.4 Ensure logrotate assigns appropriate permissions (Automated)
rule-4.4()
{
    print_rule_banner "Ensure logrotate assigns appropriate permissions"
    sed -i 's/^\s*create.*/create 0640 root utmp/g' ${LOGROTATE_CONF} /etc/logrotate.d/*
}

execute_ruleset-4()
{
    local -A rulehash

    # Remove old audit rule files
    rm -f ${AUDIT_RULE_DIR}/$(printf ${AUDIT_PAT_NAME} "*")

    # Remove old syslog conf files
    rm -f $(printf "${SYSLOG_PAT_PATH}" "rule-4*")

    local common="4.2.1.1 4.2.1.2 4.2.1.3 4.2.1.4 4.2.1.5 4.2.1.6 4.2.2.1\
        4.2.2.2 4.2.2.3 4.2.3 4.3 4.4"
    rulehash[lvl1_server]="$common"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"" 4.1.1.1 4.1.1.2 4.1.1.3\
        4.1.1.4 4.1.2.1 4.1.2.2 4.1.2.3 4.1.3 4.1.4 4.1.5 4.1.6 4.1.7 4.1.8\
        4.1.9 4.1.10 4.1.11 4.1.12 4.1.13 4.1.14 4.1.15 4.1.16 4.1.17"
    rulehash[lvl1_workstation]="$common"
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 4.1.1.1\
        4.1.1.2 4.1.1.3 4.1.1.4 4.1.2.1 4.1.2.2 4.1.2.3 4.1.3 4.1.4 4.1.5\
        4.1.6 4.1.7 4.1.8 4.1.9 4.1.10 4.1.11 4.1.12 4.1.13 4.1.14 4.1.15\
        4.1.16 4.1.17"

    rulehash[custom]=$(read_rules_list 4)

    local AUDIT_FILES=$(printf ${AUDIT_RULE_DIR}/${AUDIT_PAT_NAME} 'rule-4*')
    local SYSLOG_FILES=$(printf ${SYSLOG_PAT_PATH} 'rule-4*')

    # remove old audit rules and old syslog configuration files
    rm -f ${AUDIT_FILES} ${SYSLOG_FILES}

    do_execute_rules ${rulehash[$1]}

    # If auditd is installed, make sure you reload the audit rules
    is_installed auditd && augenrules --load
}
