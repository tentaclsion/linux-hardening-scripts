#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

########################## SUPPORT FUNCTIONS #################################

# Disable a inetd/xinetd service 
disable_inetd_service()
{
    local svcname=$1

    sed -i -E "s/^$svcname/#$svcname/" /etc/inetd.d/$svcname
    sed -i -E 's/(disable[[:space:]]*=[[:space:]]*)no/\1yes/' /etc/xinetd.d/$svcname
}

# Validate ntp service
validate_ntp_service()
{
    local svcname=`read_usr_param time_sync_svc`
    test -z "$svcname" && return 0
    if [ "$svcname" == ntp ] || [ "$svcname" == chrony ]; then
        echo -n "$svcname"
    fi
}

########################## RULE FUNCTIONS #################################

# 2.1.1 Ensure xinetd is not installed  (Automated)
rule-2.1.1()
{
    print_rule_banner "Ensure xinetd is not installed"
    dpkg -P xinetd
}

# 2.1.2 Ensure openbsd-inetd is not installed (Automated)
rule-2.1.2()
{
    print_rule_banner "Ensure openbsd-inetd is not installed"
    apt-get remove openbsd-inetd -y
}

# 2.2.1.1 Ensure time synchronization is in use (Automated)
rule-2.2.1.1()
{
    local svc=`validate_ntp_service`
    print_rule_banner "Ensure time synchronization is in use"
    if [ -z "$svc" ]; then
        echo "No time synchronization package chosen. None will be installed"
    else
        apt-get install $svc -y
    fi
}

# 2.2.1.2 Ensure systemd-timesyncd is configured (Manual)
rule-2.2.1.2()
{
    local banner="Ensure systemd-timesyncd is configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}


# 2.2.1.3 Ensure chrony is configured (Automated)
rule-2.2.1.3()
{
    local svc=`validate_ntp_service`
    local addr=`read_usr_param time_sync_addr`
    print_rule_banner "Ensure chrony is configured"
    if [ "$svc" == chrony ]; then
        egrep "^(server|pool)" /etc/chrony/chrony.conf
        if [ $? -ne 0 ]; then
           echo "pool $addr" >> /etc/chrony/chrony.conf
        fi
    else
        echo "chrony not selected for configuration"
    fi
}

# 2.2.1.4 Ensure ntp is configured (Automated)
rule-2.2.1.4()
{
    local svc=`validate_ntp_service`
    local addr=`read_usr_param time_sync_addr`
    print_rule_banner "Ensure ntp is configured"
    if [ "$svc" == ntp ]; then
        sed -i 's/^\(RUNASUSER=\).*$/\1ntp/' /etc/init.d/ntp
        egrep "restrict -4 default kod notrap nomodify nopeer noquery" /etc/ntp.conf
        if [ $? -ne 0 ]; then
            sed -i 's/^\(restrict -4.*\)$/#\1\nrestrict -4 default kod notrap nomodify nopeer noquery/' /etc/ntp.conf
        fi
        egrep "restrict -6 default kod notrap nomodify nopeer noquery" /etc/ntp.conf
        if [ $? -ne 0 ]; then
            sed -i 's/^\(restrict -6.*\)$/#\1\nrestrict -6 default kod notrap nomodify nopeer noquery/' /etc/ntp.conf
        fi
        egrep "^(server|pool)" /etc/ntp.conf
        if [ $? -ne 0 ]; then
             echo "pool $addr" >> /etc/ntp.conf
        fi
    else
        echo "ntp not selected for configuration - rule does not apply."
    fi
}

# 2.2.2 Ensure X Window System is not installed (Automated)
rule-2.2.2()
{
    print_rule_banner "Ensure X Window System is not installed"
    apt-get remove xserver-xorg -y
}

# 2.2.3 Ensure Avahi Server is not enabled (Automated)
rule-2.2.3()
{
    print_rule_banner "Ensure Avahi Server is not enabled"
    systemctl --now disable avahi-daemon
}

# 2.2.4 Ensure CUPS is not installed (Automated)
rule-2.2.4()
{
    print_rule_banner "Ensure CUPS is not installed"
    apt-get remove cups -y
}

# 2.2.5 Ensure DHCP Server is not installed (Automated)
rule-2.2.5()
{
    print_rule_banner "Ensure DHCP Server is not installed"
    apt-get remove isc-dhcp-server -y
}

# 2.2.6 Ensure LDAP server is not installed (Automated)
rule-2.2.6()
{
    print_rule_banner "Ensure LDAP server is not installed"
    apt-get remove slapd -y
}

# 2.2.7 Ensure NFS is not installed (Automated)
rule-2.2.7()
{
    print_rule_banner "Ensure NFS is not installed"
    apt-get remove nfs-kernel-server -y
}

# 2.2.8 Ensure DNS Server is not installed (Automated)
rule-2.2.8()
{
    print_rule_banner "Ensure DNS Server is not installed"
    apt-get remove bind9 -y
}

# 2.2.9 Ensure FTP Server is not installed (Automated)
rule-2.2.9()
{
    print_rule_banner "Ensure FTP Server is not installed"
    apt-get remove vsftpd -y
}

# 2.2.10 Ensure HTTP server is not installed (Automated)
rule-2.2.10()
{
    print_rule_banner "Ensure HTTP server is not installed"
    apt-get remove apache2 -y
}

# 2.2.11 Ensure IMAP and POP3 server are not installed (Automated)
rule-2.2.11()
{
    print_rule_banner "Ensure IMAP and POP3 server are not installed"
    apt-get remove dovecot-imapd dovecot-pop3d -y
}

# 2.2.12 Ensure Samba is not installed (Automated)
rule-2.2.12()
{
    print_rule_banner "Ensure Samba is not installed"
    apt-get remove samba -y
}

# 2.2.13 Ensure HTTP Proxy Server is not installed (Automated)
rule-2.2.13()
{
    print_rule_banner "Ensure HTTP Proxy Server is not installed"
    apt-get remove squid -y
}

# 2.2.14 Ensure SNMP Server is not installed (Automated)
rule-2.2.14()
{
    print_rule_banner "Ensure SNMP Server is not installed"
    apt-get remove snmpd -y
}

#2.2.15 Ensure mail transfer agent is configured for local-only mode (Automated)
rule-2.2.15()
{
    print_rule_banner "Ensure mail transfer agent is configured for local-only mode"
    sed -i "s/\("inet_interfaces" *= *\).*/\1"loopback-only"/" /etc/postfix/main.cf
    systemctl restart postfix
}

# 2.2.16 Ensure rsync service is not installed (Automated)
rule-2.2.16()
{
    print_rule_banner "Ensure rsync service is not installed"
    apt-get remove rsync -y
}

# 2.2.17 Ensure NIS Server is not installed (Automated)
rule-2.2.17()
{
    print_rule_banner "Ensure NIS Server is not installed"
    apt-get remove nis -y
}

# 2.3.1 Ensure NIS Client is not installed (Automated)
rule-2.3.1()
{
    print_rule_banner "Ensure NIS Client is not installed"
    dpkg -P purge nis
}

# 2.3.2 Ensure rsh client is not installed (Automated)
rule-2.3.2()
{
    print_rule_banner "Ensure rsh client is not installed"
    apt-get remove rsh-client -y
}

# 2.3.3 Ensure talk client is not installed (Automated)
rule-2.3.3()
{
    print_rule_banner "Ensure talk client is not installed"
    apt-get remove talk -y
}

# 2.3.4 Ensure telnet client is not installed (Automated)
rule-2.3.4()
{
    print_rule_banner "Ensure telnet client is not installed"
    dpkg -P telnet
}

# 2.3.5 Ensure LDAP client is not installed (Automated)
rule-2.3.5()
{
    print_rule_banner "Ensure LDAP client is not installed"
    dpkg -P ldap-utils
}

# 2.3.6 Ensure RPC is not installed (Automated)
rule-2.3.6()
{
    print_rule_banner "Ensure RPC is not installed"
    dpkg -P rpcbind
}

#2.4 Ensure nonessential services are removed or masked (Manual)
rule-2.4()
{
    local banner="Ensure nonessential services are removed or masked"
    print_rule_banner "${banner}"
    print_manual_req_msg "${banner}"
}

execute_ruleset-2()
{
    local -A rulehash
    local common="2.1.1 2.1.2 2.2.1.1 2.2.1.2 2.2.1.3 2.2.1.4 2.2.3 2.2.5\
        2.2.6 2.2.7 2.2.8 2.2.9 2.2.10 2.2.11 2.2.12 2.2.13 2.2.14 2.2.15\
        2.2.16 2.2.17 2.3.1 2.3.2 2.3.3 2.3.4 2.3.5 2.3.6 2.4"
    rulehash[lvl1_server]="$common"" 2.2.2 2.2.4"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"
    rulehash[lvl1_workstation]="$common"
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 2.2.4"

    rulehash[custom]=$(read_rules_list 2)

    do_execute_rules ${rulehash[$1]}
}
