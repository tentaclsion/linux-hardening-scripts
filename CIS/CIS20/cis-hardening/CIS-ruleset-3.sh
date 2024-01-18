#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

# Global vars
# iptables save files
IPTABLES_v4_file=/etc/iptables/rules.v4
IPTABLES_v6_file=/etc/iptables/rules.v6

########################## SUPPORT FUNCTIONS #################################

ensure_iptables()
{
    # Make sure iptables and iptables-persistent is installed
    is_installed iptables
    if [ $? -ne 0 ]; then
        apt-get install -y iptables
    fi
    is_installed iptables-persistent
    if [ $? -ne 0 ]; then
        debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
        debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
        apt-get install -y iptables-persistent
    fi
}

remove_sysctl() {
    local param="$1"

    sed -i '/^\s*'"$param"'=.*/d' /etc/sysctl.conf /etc/sysctl.d/*
}


########################## RULE FUNCTIONS #################################
#3.1.1 Disable IPv6 (Manual)
rule-3.1.1()
{
    local banner="Disable IPv6"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.1.2 Ensure wireless interfaces are disabled (Automated)
rule-3.1.2()
{
    print_rule_banner "Ensure wireless interfaces are disabled"


    if [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
        drivers=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
        for dm in $drivers; do
            echo "install $dm /bin/true" >> /etc/modprobe.d/disable_wireless.conf
            modprobe -r $dm
        done
    fi

    if command -v nmcli >/dev/null 2>&1 ; then
        nmcli radio all off
    fi
}

#3.2.1 Ensure packet redirect sending is disabled (Automated)
rule-3.2.1()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure packet redirect sending is disabled"

    remove_sysctl "net.ipv4.conf.all.send_redirects"
    remove_sysctl "net.ipv4.conf.default.send_redirects"

    echo "net.ipv4.conf.all.send_redirects=0" > ${outfile}
    echo "net.ipv4.conf.default.send_redirects=0" >> ${outfile}

    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.conf.default.send_redirects=0
    sysctl -w net.ipv4.route.flush=1
}

#3.2.2 Ensure IP forwarding is disabled (Automated)
rule-3.2.2()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure IP forwarding is disabled"

    remove_sysctl "net.ipv4.ip_forward"
    remove_sysctl "net.ipv6.conf.all.forwarding"

    echo "net.ipv4.ip_forward=0" > ${outfile}
    echo "net.ipv6.conf.all.forwarding=0" >> ${outfile}

    sysctl -w net.ipv4.ip_forward=0
    sysctl -w net.ipv4.route.flush=1
    sysctl -w net.ipv6.conf.all.forwarding=0
    sysctl -w net.ipv6.route.flush=1
}

#3.3.1 Ensure source routed packets are not accepted (Automated)
rule-3.3.1()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure source routed packets are not accepted"

    remove_sysctl "net.ipv4.conf.all.accept_source_route"
    remove_sysctl "net.ipv4.conf.default.accept_source_route"
    remove_sysctl "net.ipv6.conf.all.accept_source_route"
    remove_sysctl "net.ipv6.conf.default.accept_source_route"

    echo "net.ipv4.conf.all.accept_source_route=0" > ${outfile}
    echo "net.ipv4.conf.default.accept_source_route=0" >> ${outfile}
    echo "net.ipv6.conf.all.accept_source_route=0" >> ${outfile}
    echo "net.ipv6.conf.default.accept_source_route=0" >> ${outfile}

    sysctl -w net.ipv4.conf.all.accept_source_route=0
    sysctl -w net.ipv4.conf.default.accept_source_route=0
    sysctl -w net.ipv4.route.flush=1
    sysctl -w net.ipv6.conf.all.accept_source_route=0
    sysctl -w net.ipv6.conf.default.accept_source_route=0
    sysctl -w net.ipv6.route.flush=1
}

#3.3.2 Ensure ICMP redirects are not accepted (Automated)
rule-3.3.2()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure ICMP redirects are not accepted"

    remove_sysctl "net.ipv4.conf.all.accept_redirects"
    remove_sysctl "net.ipv4.conf.default.accept_redirects"
    remove_sysctl "net.ipv6.conf.all.accept_redirects"
    remove_sysctl "net.ipv6.conf.default.accept_redirects"

    echo "net.ipv4.conf.all.accept_redirects=0" > ${outfile}
    echo "net.ipv4.conf.default.accept_redirects=0" >> ${outfile}
    echo "net.ipv6.conf.all.accept_redirects=0" >> ${outfile}
    echo "net.ipv6.conf.default.accept_redirects=0" >> ${outfile}

    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.default.accept_redirects=0
    sysctl -w net.ipv4.route.flush=1
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.default.accept_redirects=0
    sysctl -w net.ipv6.route.flush=1
}

#3.3.3 Ensure secure ICMP redirects are not accepted (Automated)
rule-3.3.3()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"
    print_rule_banner "Ensure secure ICMP redirects are not accepted"

    remove_sysctl "net.ipv4.conf.all.secure_redirects"
    remove_sysctl "net.ipv4.conf.default.secure_redirects"

    echo "net.ipv4.conf.all.secure_redirects=0" > ${outfile}
    echo "net.ipv4.conf.default.secure_redirects=0" >> ${outfile}

    sysctl -w net.ipv4.conf.all.secure_redirects=0
    sysctl -w net.ipv4.conf.default.secure_redirects=0
    sysctl -w net.ipv4.route.flush=1
}

#3.3.4 Ensure suspicious packets are logged (Automated)
rule-3.3.4()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure suspicious packets are logged"

    remove_sysctl "net.ipv4.conf.all.log_martians"
    remove_sysctl "net.ipv4.conf.default.log_martians"

    echo "net.ipv4.conf.all.log_martians=1" > ${outfile}
    echo "net.ipv4.conf.default.log_martians=1" >> ${outfile}

    sysctl -w net.ipv4.conf.all.log_martians=1
    sysctl -w net.ipv4.conf.default.log_martians=1
    sysctl -w net.ipv4.route.flush=1
}

#3.3.5 Ensure broadcast ICMP requests are ignored (Automated)
rule-3.3.5()
{
    print_rule_banner "Ensure broadcast ICMP requests are ignored"

    remove_sysctl "net.ipv4.icmp_echo_ignore_broadcasts"

    echo "net.ipv4.icmp_echo_ignore_broadcasts=1" > "$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
    sysctl -w net.ipv4.route.flush=1
}

#3.3.6 Ensure bogus ICMP responses are ignored (Automated)
rule-3.3.6()
{
    print_rule_banner "Ensure bogus ICMP responses are ignored"

    remove_sysctl "net.ipv4.icmp_ignore_bogus_error_responses"

    echo "net.ipv4.icmp_ignore_bogus_error_responses=1" > "$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1
    sysctl -w net.ipv4.route.flush=1
}

#3.3.7 Ensure Reverse Path Filtering is enabled (Automated)
rule-3.3.7()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure Reverse Path Filtering is enabled"

    remove_sysctl "net.ipv4.conf.all.rp_filter"
    remove_sysctl "net.ipv4.conf.default.rp_filter"

    echo "net.ipv4.conf.all.rp_filter=1" > ${outfile}
    echo "net.ipv4.conf.default.rp_filter=1" >> ${outfile}

    sysctl -w net.ipv4.conf.all.rp_filter=1
    sysctl -w net.ipv4.conf.default.rp_filter=1
    sysctl -w net.ipv4.route.flush=1
}

#3.3.8 Ensure TCP SYN Cookies is enabled (Automated)
rule-3.3.8()
{
    print_rule_banner "Ensure TCP SYN Cookies is enabled"

    remove_sysctl "net.ipv4.tcp_syncookies"

    echo "net.ipv4.tcp_syncookies=1" > "$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -w net.ipv4.route.flush=1
}

#3.3.9 Ensure IPv6 router advertisements are not accepted (Automated)
rule-3.3.9()
{
    local outfile="$(printf ${SYSCTLD_PAT_PATH} ${FUNCNAME})"

    print_rule_banner "Ensure IPv6 router advertisements are not accepted"

    remove_sysctl "net.ipv6.conf.all.accept_ra"
    remove_sysctl "net.ipv6.conf.default.accept_ra"

    echo "net.ipv6.conf.all.accept_ra=0" > ${outfile}
    echo "net.ipv6.conf.default.accept_ra=0" >> ${outfile}

    sysctl -w net.ipv6.conf.all.accept_ra=0
    sysctl -w net.ipv6.conf.default.accept_ra=0
    sysctl -w net.ipv6.route.flush=1
}

#3.4.1 Ensure DCCP is disabled (Automated)
rule-3.4.1()
{
    print_rule_banner "Ensure DCCP is disabled"
    disable_mod dccp
}

#3.4.2 Ensure SCTP is disabled (Automated)
rule-3.4.2()
{
    print_rule_banner "Ensure SCTP is disabled"
    disable_mod sctp
}

#3.4.3 Ensure RDS is disabled (Automated)
rule-3.4.3()
{
    print_rule_banner "Ensure RDS is disabled"
    disable_mod rds
}

#3.4.4 Ensure TIPC is disabled (Automated)
rule-3.4.4()
{
    print_rule_banner "Ensure TIPC is disabled"
    disable_mod tipc
}

# ufw rules go from 3.5.1.1 to 3.5.1.7 are not automatically executed
# because the hardening scripts rely upon iptables instead.
# According to the CIS document, only one is required.

#3.5.1.1 Ensure Uncomplicated Firewall is installed (Manual | Benchmark Automated)
rule-3.5.1.1()
{
    print_rule_banner "Ensure Uncomplicated Firewall is installed"
    echo "Ensure Uncomplicated Firewall is installed - not supported: only iptables is supported"
}

#3.5.1.2 Ensure iptables-persistent is not installed (Manual | Benchmark Automated)
rule-3.5.1.2()
{
    print_rule_banner "Ensure iptables-persistent is not installed"
    echo "Ensure iptables-persistent is not installed - not supported: only iptables is supported"
}

#3.5.1.3 Ensure ufw service is enabled (Manual | Benchmark Automated)
rule-3.5.1.3()
{
    print_rule_banner "Ensure ufw service is enabled"
    echo "Ensure ufw service is enabled - not supported: only iptables is supported"
}

#3.5.1.4 Ensure loopback traffic is configured (Manual | Benchmark Automated)
rule-3.5.1.4()
{
    print_rule_banner "Ensure loopback traffic is configured"
    echo "Ensure loopback traffic is configured - not supported: only iptables is supported"
}

#3.5.1.5 Ensure outbound connections are configured (Manual)
rule-3.5.1.5()
{
    print_rule_banner "Ensure outbound connections are configured"
    echo "Ensure outbound connections are configured - not supported: only iptables is supported"
}

#3.5.1.6 Ensure firewall rules exist for all open ports (Manual | Benchmark Automated)
rule-3.5.1.6()
{
    print_rule_banner "Ensure firewall rules exist for all open ports"
    echo "Ensure firewall rules exist for all open ports - not supported: only iptables is supported"
}

#3.5.1.7 Ensure default deny firewall policy (Manual | Benchmark Automated)
rule-3.5.1.7()
{
    print_rule_banner "Ensure default deny firewall policy"
    echo "Ensure default deny firewall policy - not supported: only iptables is supported"
}


# nftables rules go from 3.5.2.1 to 3.5.2.10 are not automatically executed
# because the hardening scripts rely upon iptables instead.
# According to the CIS document, only one is required.

#3.5.2.1 Ensure nftables is installed (Manual | Benchmark Automated)
rule-3.5.2.1()
{
    print_rule_banner "Ensure nftables is installed"
    echo "Ensure nftables is installed - not supported: only iptables is supported"
}

#3.5.2.2 Ensure Uncomplicated Firewall is not installed or disabled (Manual | Benchmark Automated)
rule-3.5.2.2()
{
    print_rule_banner "Ensure Uncomplicated Firewall is not installed or disabled"
    echo "Ensure Uncomplicated Firewall is not installed or disabled - not supported: only iptables is supported"
}

#3.5.2.3 Ensure iptables are flushed (Manual)
rule-3.5.2.3()
{
    print_rule_banner "Ensure iptables are flushed"
    echo "Ensure iptables are flushed - not supported: only iptables is supported"
}

#3.5.2.4 Ensure a table exists (Manual | Benchmark Automated)
rule-3.5.2.4()
{
    print_rule_banner "Ensure a table exists"
    echo "Ensure a table exists - not supported: only iptables is supported"
}

#3.5.2.5 Ensure base chains exist (Manual | Benchmark Automated)
rule-3.5.2.5()
{
    print_rule_banner "Ensure base chains exist"
    echo "Ensure base chains exist - not supported: only iptables is supported"
}

#3.5.2.6 Ensure loopback traffic is configured (Manual | Benchmark Automated)
rule-3.5.2.6()
{
    print_rule_banner "Ensure loopback traffic is configured"
    echo "Ensure loopback traffic is configured - not supported: only iptables is supported"
}

#3.5.2.7 Ensure outbound and established connections are configured (Manual)
rule-3.5.2.7()
{
    print_rule_banner "Ensure outbound and established connections are configured"
    echo "Ensure outbound and established connections are configured - not supported: only iptables is supported"
}

#3.5.2.8 Ensure default deny firewall policy (Manual | Benchmark Automated)
rule-3.5.2.8()
{
    print_rule_banner "Ensure default deny firewall policy"
    echo "Ensure default deny firewall policy - not supported: only iptables is supported"
}

#3.5.2.9 Ensure nftables service is enabled (Manual | Benchmark Automated)
rule-3.5.2.9()
{
    print_rule_banner "Ensure nftables service is enabled"
    echo "Ensure nftables service is enabled - not supported: only iptables is supported"
}

#3.5.2.10 Ensure nftables rules are permanent (Manual | Benchmark Automated)
rule-3.5.2.10()
{
    print_rule_banner "Ensure nftables rules are permanent"
    echo "Ensure nftables rules are permanent - not supported: only iptables is supported"
}

# Rules from 3.5.3.2.1 to 3.5.3.2.4 and 3.5.3.3.1 to 3.5.3.3.4 use iptables
# the first 4 for IPv4 and the latter ones for IPv6

#3.5.3.1.1 Ensure iptables packages are installed (Automated)
rule-3.5.3.1.1()
{
    local banner="Ensure iptables packages are installed"
    print_rule_banner "${banner}"

    ensure_iptables
}

#3.5.3.1.2 Ensure nftables is not installed (Automated)
rule-3.5.3.1.2()
{
    local banner="Ensure nftables is not installed"
    print_rule_banner "${banner}"

    apt-get purge nftables -y
}

#3.5.3.1.3 Ensure Uncomplicated Firewall is not installed or disabled (Automated)
rule-3.5.3.1.3()
{
    local banner="Ensure Uncomplicated Firewall is not installed or disabled"
    print_rule_banner "${banner}"

    apt-get purge ufw -y
}

#3.5.3.2.1 Ensure default deny firewall policy (Manual | Benchmark Automated)
rule-3.5.3.2.1()
{
    local banner="Ensure default deny firewall policy"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.5.3.2.2 Ensure loopback traffic is configured (Automated)
rule-3.5.3.2.2()
{
    print_rule_banner "Ensure loopback traffic is configured"

    ensure_iptables

    iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || iptables -A INPUT -i lo -j ACCEPT
    iptables -C OUTPUT -o lo -j ACCEPT 2>/dev/null || iptables -A OUTPUT -o lo -j ACCEPT
    iptables -C INPUT -s 127.0.0.0/8 -j DROP 2>/dev/null || iptables -A INPUT -s 127.0.0.0/8 -j DROP
    iptables-save > ${IPTABLES_v4_file}
}

#3.5.3.2.3 Ensure outbound and established connections are configured (Manual)
rule-3.5.3.2.3()
{
    local banner="Ensure outbound and established connections are configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.5.3.2.4 Ensure firewall rules exist for all open ports (Manual | Benchmark Automated)
rule-3.5.3.2.4()
{
    local banner="Ensure firewall rules exist for all open ports"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.5.3.3.1 Ensure IPv6 default deny firewall policy (Manual | Benchmark Automated)
rule-3.5.3.3.1()
{
    local banner="Ensure IPv6 default deny firewall policy"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.5.3.3.2 Ensure IPv6 loopback traffic is configured (Automated)
rule-3.5.3.3.2()
{
    print_rule_banner "Ensure IPv6 loopback traffic is configured"

    ensure_iptables

    ip6tables -C INPUT -i lo -j ACCEPT 2>/dev/null || ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -C OUTPUT -o lo -j ACCEPT 2>/dev/null || ip6tables -A OUTPUT -o lo -j ACCEPT
    ip6tables -C INPUT -s ::1 -j DROP 2>/dev/null || ip6tables -A INPUT -s ::1 -j DROP
    ip6tables-save > ${IPTABLES_v6_file}
}

#3.5.3.3.3 Ensure IPv6 outbound and established connections are configured (Manual)
rule-3.5.3.3.3()
{
    local banner="Ensure outbound and established IPv6 connections are configured"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#3.5.3.3.4 Ensure IPv6 firewall rules exist for all open ports (Manual)
rule-3.5.3.3.4()
{
    local banner="Ensure IPv6 firewall rules exist for all open ports"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

# We only support iptables at this point, so rules 3.5.1.1-3.5.1.7 and 3.5.2.1-3.5.2.10
# which deal with ufw and nftables, are just placeholders and are not executed by default.
execute_ruleset-3()
{
    local -A rulehash
    local common="3.2.1 3.2.2 3.3.1 3.3.2 3.3.3 3.3.4 3.3.5 3.3.6 3.3.7 3.3.8\
        3.3.9 3.5.1.1 3.5.1.2 3.5.1.3 3.5.1.4 3.5.1.5 3.5.1.6 3.5.1.7 3.5.2.1\
        3.5.2.2 3.5.2.3 3.5.2.4 3.5.2.5 3.5.2.6 3.5.2.7 3.5.2.8 3.5.2.9\
        3.5.2.10 3.5.3.1.1 3.5.3.1.2 3.5.3.1.3 3.5.3.2.1 3.5.3.2.2 3.5.3.2.3\
        3.5.3.2.4 3.5.3.3.1 3.5.3.3.2 3.5.3.3.3 3.5.3.3.4"
    rulehash[lvl1_server]="$common"" 3.1.2"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"" 3.1.1 3.4.1 3.4.2 3.4.3\
        3.4.4"
    rulehash[lvl1_workstation]="$common"
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 3.1.1 3.1.2\
        3.4.1 3.4.2 3.4.3 3.4.4"

    rulehash[custom]=$(read_rules_list 3)

    # Remove /etc/sysctl.d files
    rm -f $(printf ${SYSCTLD_PAT_PATH} 'rule-3*')

    do_execute_rules ${rulehash[$1]}
}
