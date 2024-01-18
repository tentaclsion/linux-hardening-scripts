#!/bin/bash
#Section 3 Network Configuration

if [ "$EUID" -ne 0 ]
then
    echo "Run script as root"
    exit
fi
ubu () {
    #3.1.1 Ensure packet redirect sending is disabled
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.conf.default.send_redirects=0 
    sysctl -w net.ipv4.route.flush=1

    #3.1.2 Ensure IP forwarding is disabled
    grep -Els "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv4\.ip_forward\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv4.ip_forward=0; sysctl -w net.ipv4.route.flush=1
    grep -Els "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv6\.conf\.all\.forwarding\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv6.conf.all.forwarding=0; sysctl -w net.ipv6.route.flush=1

    #3.2.1 Ensure source routed packets are not accepted
    sysctl -w net.ipv4.conf.all.accept_source_route=0 
    sysctl -w net.ipv4.conf.default.accept_source_route=0 
    sysctl -w net.ipv6.conf.all.accept_source_route=0 
    sysctl -w net.ipv6.conf.default.accept_source_route=0 
    sysctl -w net.ipv4.route.flush=1 
    sysctl -w net.ipv6.route.flush=1

    #3.2.2 Ensure ICMP redirects are not accepted
    sysctl -w net.ipv4.conf.all.accept_redirects=0 
    sysctl -w net.ipv4.conf.default.accept_redirects=0 
    sysctl -w net.ipv6.conf.all.accept_redirects=0 
    sysctl -w net.ipv6.conf.default.accept_redirects=0 
    sysctl -w net.ipv4.route.flush=1 
    sysctl -w net.ipv6.route.flush=1

    #3.2.3 Ensure secure ICMP redirects are not accepted
    sysctl -w net.ipv4.conf.all.secure_redirects=0
    sysctl -w net.ipv4.conf.default.secure_redirects=0
    sysctl -w net.ipv4.route.flush=1

    #3.2.4 Ensure suspicious packets are logged
    sysctl -w net.ipv4.conf.all.log_martians=1 
    sysctl -w net.ipv4.conf.default.log_martians=1 
    sysctl -w net.ipv4.route.flush=1    

    #3.2.5 Ensure broadcast ICMP requests are ignored
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.6 Ensure bogus ICMP responses are ignored
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.7 Ensure Reverse Path Filtering is enabled
    sysctl -w net.ipv4.conf.all.rp_filter=1 
    sysctl -w net.ipv4.conf.default.rp_filter=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.8 Ensure TCP SYN Cookies is enabled
    sysctl -w net.ipv4.tcp_syncookies=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.9 Ensure IPv6 router advertisements are not accepted
    sysctl -w net.ipv6.conf.all.accept_ra=0 
    sysctl -w net.ipv6.conf.default.accept_ra=0 
    sysctl -w net.ipv6.route.flush=1

    #3.3.1 Ensure TCP Wrappers is installed
    apt-get install tcpd

    #3.3.2 Ensure /etc/hosts.allow is configured
    #3.3.3 Ensure /etc/hosts.deny is configured

    #3.3.4 Ensure permissions on /etc/hosts.allow are configured
    chown root:root /etc/hosts.allow 
    chmod 644 /etc/hosts.allow

    #3.3.5 Ensure permissions on /etc/hosts.deny are configured
    chown root:root /etc/hosts.deny 
    chmod 644 /etc/hosts.deny

    #3.4.1 Ensure DCCP is disabled
    dccpAudit=$(modprobe -n -v dccp)
    if [[ ! $dccpAudit =~ "install /bin/true" ]]    
    then
        touch /etc/modprobe.d/dccp.conf; echo -e "install dccp /bin/true" | tee --append /etc/modprobe.d/dccp.conf
    fi

    #3.4.2 Ensure SCTP is disabled
    sctpAudit=$(modprobe -n -v sctp)
    if [[ ! $sctpAudit =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/sctp.conf; echo -e "install sctp /bin/true" | tee --append /etc/modprobe.d/sctp.conf
    fi

    #3.4.3 Ensure RDS is disabled
    rdsAudit=$(modprobe -n -v rds)
    if [[ ! $rdsAudit =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/rds.conf; echo -e "install rds /bin/true" | tee --append /etc/modprobe.d/rds.conf
    fi

    #3.4.4 Ensure TIPC is disabled
    tipcAudit=$(modprobe -n -v tipc)
    if [[ ! $tipcAudit =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/tipc.conf; echo -e "install tipc /bin/true" | tee --append /etc/modprobe.d/tipc.conf
    fi

    #3.5.1.1 Ensure a Firewall package is installed
    ufwAudit=$(dpkg -s ufw | grep -i status)
    if [[ ! $ufwAudit =~ "Status: install ok installed" ]]
    then
        apt-get install ufw
    fi

    nftablesAudit=$(dpkg -s nftables | grep -i status)
    if [[ ! $nftablesAudit =~ "Status: install ok installed" ]]
    then
        apt-get install nftables
    fi

    iptablesAudit=$(dpkg -s iptables | grep -i status)
    if [[ ! $iptables =~ "Status: install ok installed" ]]
    then
        apt-get install iptables
    fi    

    #3.5.2.1 Configure UncomplicatedFirewall
    if [[ ! $(systemctl is-enabled ufw) =~ "enabled" ]]
    then
        ufw allow proto tcp from any to any port 22
        ufw --force enable
    fi

    #3.5.2.2 Ensure default deny firewall policy
    ufw default deny incoming
    ufw default deny outgoing
    ufw default deny routed
    
    #3.5.2.3 Ensure loopback traffic is configured
    ufw allow in on lo 
    ufw deny in from 127.0.0.0/8 
    ufw deny in from ::1

    #3.5.2.4 Ensure outbound connections are configured
    ufw allow out to any port 80
    
    #3.5.2.5 Ensure firewall rules exist for all open ports
    #ss -4tuln determine open ports
    #ufw status
    #ufw allow in <port>/<tcp or udp protocol>
    echo -e "3.5.2.5"
    echo -e "To Determine Open Ports: ss -4tuln"
    echo -e "To Determine Firewall Rules: ufw status"
    echo -e "For every port which does not have a firewall rule established: ufw allow in <port>/<tcp or udp protocol>"

    #3.5.3 Configure nftables
    if [[ ! $(ls | grep nftables.rules) =~ "nftables.rules" ]]
    then
        echo "<*>Transfer the preconfigured nftables.rules file into Desktop"
    else
        mv nftables.rules /etc/nftables/nftables.rules
        nft -f /etc/nftables/nftables.rules
        nft list ruleset > /etc/nftables/nftables.rules
        echo -e 'include "/etc/nftables/nftables.rules"' | tee --append /etc/sysconfig/nftables.conf

    #3.5.3.1 Ensure iptables are flushed
    iptables -F

    #3.5.3.2 Ensure a table exists
    nft create table inet filter

    #3.5.3.3 Ensure base chains exist
    nft create chain inet filter input { type filter hook input priority 0 \; } 
    nft create chain inet filter forward { type filter hook forward priority 0 \; } 
    nft create chain inet filter output { type filter hook output priority 0 \; }

    #3.5.3.4 Ensure loopback traffic is configured
    nft add rule inet filter input iif lo accept 
    nft create rule inet filter input ip saddr 127.0.0.0/8 counter drop 
    nft add rule inet filter input ip6 saddr ::1 counter drop

    #3.5.3.5 Ensure outbound and established connections are configured
    nft add rule inet filter input ip protocol tcp ct state established accept 
    nft add rule inet filter input ip protocol udp ct state established accept 
    nft add rule inet filter input ip protocol icmp ct state established accept 
    nft add rule inet filter output ip protocol tcp ct state new,related,established accept 
    nft add rule inet filter output ip protocol udp ct state new,related,established accept
    nft add rule inet filter output ip protocol icmp ct state new,related,established accept

    #3.5.3.6 Ensure default deny firewall policy
    #add a rule allowing ssh in the base chain prior to setting the base cains policy to drop
    nft chain inet filter input { policy drop \; } 
    nft chain inet filter forward { policy drop \; } 
    nft chain inet filter output { policy drop \; }

    #3.5.3.7 Ensure nftables service is enabled
    if [[ ! $(systemctl is-enabled nftables) =~ "enabled" ]]
    then
        systemctl enable nftables
    fi

    #3.5.3.8 Ensure nftables rules are permanent
    #Already done in 3.5.3

    #3.5.4.1 Configure IPv4 iptables
    iptables -F
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A INPUT -s 127.0.0.0/8 -j DROP
    iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

    #3.5.4.1.1 Ensure default deny firewall policy
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP

    #3.5.4.1.2 Ensure loopback traffic is configured
    iptables -A INPUT -i lo -j ACCEPT 
    iptables -A OUTPUT -o lo -j ACCEPT 
    iptables -A INPUT -s 127.0.0.0/8 -j DROP

    #3.5.4.1.3 Ensure outbound and established connections are configured
    iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

    #3.5.4.1.4 Ensure firewall rules exist for all open ports
    #ss -4tuln determine open ports
    #iptables -L INPUT -v -n to determine firewall rules
    #iptables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT
    echo -e "3.5.4.1.4"
    echo -e "To Determine Open Ports: ss -4tuln"
    echo -e "To Determine Firewall Rules: iptables -L INPUT -v -n"
    echo -e "For every port which does not have a firewall rule established: iptables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"

    #3.5.4.2 Configure IPv6 ip6tables
    ip6tables -F
    ip6tables -P INPUT DROP
    ip6tables -P OUTPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -A INPUT -i lo -j ACCEPT 
    ip6tables -A OUTPUT -o lo -j ACCEPT 
    ip6tables -A INPUT -s ::1 -j DROP
    ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

    #3.5.4.2.1 Ensure IPv6 default deny firewall policy
    ip6tables -P INPUT DROP
    ip6tables -P OUTPUT DROP
    ip6tables -P FORWARD DROP

    #3.5.4.2.2 Ensure IPv6 loopback traffic is configured
    ip6tables -A INPUT -i lo -j ACCEPT 
    ip6tables -A OUTPUT -o lo -j ACCEPT 
    ip6tables -A INPUT -s ::1 -j DROP

    #3.5.4.2.3 Ensure IPv6 outbound and established connections are configured
    ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

    #3.5.4.2.4 Ensure IPv6 firewall rules exist for all open ports
    #ss -4tuln determine open ports
    #ip6tables -L INPUT -v -n
    #ip6tables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT
    echo -e "3.5.4.2.4"
    echo -e "To Determine Open Ports: ss -4tuln"
    echo -e "To Determine Firewall Rules: ip6tables -L INPUT -v -n"
    echo -e "For every port which does not have a firewall rule established: ip6tables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"

    #3.6 Ensure wireless interfaces are disabled
    #Not necessary
    #nmcli radio all off

    #3.7 Disable IPv6 
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/g' /etc/default/grub
    update-grub

    #End of Ubuntu CIS Section 3
}

deb () {
    #3.1.1 Ensure IP forwarding is disabled
    sysctl -w net.ipv4.ip_forward=0 
    sysctl -w net.ipv6.conf.all.forwarding=0 
    sysctl -w net.ipv4.route.flush=1 
    sysctl -w net.ipv6.route.flush=1

    #3.1.2 Ensure packet redirect sending is disabled
    sysctl -w net.ipv4.conf.all.send_redirects=0 
    sysctl -w net.ipv4.conf.default.send_redirects=0 
    sysctl -w net.ipv4.route.flush=1

    #3.2.1 Ensure source routed packets are not accepted
    sysctl -w net.ipv4.conf.all.accept_source_route=0
    sysctl -w net.ipv4.conf.default.accept_source_route=0
    sysctl -w net.ipv6.conf.all.accept_source_route=0
    sysctl -w net.ipv6.conf.default.accept_source_route=0
    sysctl -w net.ipv4.route.flush=1
    sysctl -w net.ipv6.route.flush=1

    #3.2.2 Ensure ICMP redirects are not accepted
    sysctl -w net.ipv4.conf.all.accept_redirects=0 
    sysctl -w net.ipv4.conf.default.accept_redirects=0 
    sysctl -w net.ipv6.conf.all.accept_redirects=0 
    sysctl -w net.ipv6.conf.default.accept_redirects=0 
    sysctl -w net.ipv4.route.flush=1 
    sysctl -w net.ipv6.route.flush=1

    #3.2.3 Ensure secure ICMP redirects are not accepted
    sysctl -w net.ipv4.conf.all.secure_redirects=0 
    sysctl -w net.ipv4.conf.default.secure_redirects=0 
    sysctl -w net.ipv4.route.flush=1

    #3.2.4 Ensure suspicious packets are logged
    sysctl -w net.ipv4.conf.all.log_martians=1 
    sysctl -w net.ipv4.conf.default.log_martians=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.5 Ensure broadcast ICMP requests are ignored
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.6 Ensure bogus ICMP responses are ignored
    sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.7 Ensure Reverse Path Filtering is enabled
    sysctl -w net.ipv4.conf.all.rp_filter=1 
    sysctl -w net.ipv4.conf.default.rp_filter=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.8 Ensure TCP SYN Cookies is enabled
    sysctl -w net.ipv4.tcp_syncookies=1 
    sysctl -w net.ipv4.route.flush=1

    #3.2.9 Ensure IPv6 router advertisements are not accepted
    sysctl -w net.ipv6.conf.all.accept_ra=0 
    sysctl -w net.ipv6.conf.default.accept_ra=0 
    sysctl -w net.ipv6.route.flush=1

    #3.3.1 Ensure TCP Wrappers is installed
    #ldd <path-to-daemon> | grep libwrap.so to check if service supports TCP wrappers
    tcpdAudit=$(dpkg -s tcpd | grep -i status)
    if [[ ! $tcpdAudit =~ "Status: install ok installed" ]]
    then
        apt-get install tcpd
    fi

    #3.3.2 Ensure /etc/hosts.allow is configured
    #3.3.3 Ensure /etc/hosts.deny is configured

    #3.3.4 Ensure permissions on /etc/hosts.allow are configured
    chown root:root /etc/hosts.allow
    chmod 644 /etc/hosts.allow

    #3.3.5 Ensure permissions on /etc/hosts.deny are configured
    chown root:root /etc/hosts.deny
    chmod 644 /etc/hosts.deny

    #3.4.1 Ensure DCCP is disabled
    if [[ ! $(modprobe -n -v dccp) =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/dccp.conf; echo -e "install dccp /bin/true" | tee --append /etc/modprobe.d/dccp.conf
    fi

    #3.4.2 Ensure SCTP is disabled
    if [[ ! $(modprobe -n -v sctp) =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/sctp.conf; echo -e "install sctp /bin/true" | tee --append /etc/modprobe.d/sctp.conf
    fi

    #3.4.3 Ensure RDS is disabled
    if [[ ! $(modprobe -n -v rds) =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/rds.conf; echo -e "install rds /bin/true" | tee --append /etc/modprobe.d/rds.conf
    fi

    #3.4.4 Ensure TIPC is disabled
    if [[ ! $(modprobe -n -v tipc) =~ "install /bin/true" ]]
    then
        touch /etc/modprobe.d/tipc.conf; echo -e "install tipc /bin/true" | tee --append /etc/modprobe.d/tipc.conf
    fi

    #3.5.1 Configure IPv4 iptables
    iptables -F
    iptables -P INPUT DROP 
    iptables -P OUTPUT DROP 
    iptables -P FORWARD DROP
    iptables -A INPUT -i lo -j ACCEPT 
    iptables -A OUTPUT -o lo -j ACCEPT 
    iptables -A INPUT -s 127.0.0.0/8 -j DROP
    iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

    #3.5.1.1 Ensure default deny firewall policy
    iptables -P INPUT DROP 
    iptables -P OUTPUT DROP 
    iptables -P FORWARD DROP

    #3.5.1.2 Ensure loopback traffic is configured
    iptables -A INPUT -i lo -j ACCEPT 
    iptables -A OUTPUT -o lo -j ACCEPT 
    iptables -A INPUT -s 127.0.0.0/8 -j DROP

    #3.5.1.3 Ensure outband and established connections are configured
    iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

    #3.5.1.4 Ensure firewall rules exist for all open ports
    #To determine open ports netstat -ln
    #To determine firewall rules iptables -L INPUT -v -n
    #iptables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT
    echo -e "3.5.1.4"
    echo -e "To determine open ports: netstat -ln"
    echo -e "To determine firewall rules: iptables -L INPUT -v -n"
    echo -e "For each port which does not have a firewall rule established: iptables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"

    #3.5.2 Configure IPv6 ip6tables
    ip6tables -F
    ip6tables -P INPUT DROP 
    ip6tables -P OUTPUT DROP 
    ip6tables -P FORWARD DROP
    ip6tables -A INPUT -i lo -j ACCEPT 
    ip6tables -A OUTPUT -o lo -j ACCEPT 
    ip6tables -A INPUT -s ::1 -j DROP
    ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

    #3.5.2.1 Ensure IPv6 default deny firewall policy
    ip6tables -P INPUT DROP 
    ip6tables -P OUTPUT DROP 
    ip6tables -P FORWARD DROP

    #3.5.2.2 Ensure IPv6 loopback traffic is configured
    ip6tables -A INPUT -i lo -j ACCEPT 
    ip6tables -A OUTPUT -o lo -j ACCEPT 
    ip6tables -A INPUT -s ::1 -j DROP

    #3.5.2.3 Ensure IPv6 outbound and established connections are configured
    ip6tables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT 
    ip6tables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT

    #3.5.2.4 Ensure IPv6 firewall rules exist for all open ports
    #To determine open ports netstat -ln
    #To determine firewall rules ip6tables -L INPUT -v -n
    #ip6tables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT    
    echo -e "3.5.2.4"
    echo -e "To determine open ports: netstat -ln"
    echo -e "To determine firewall rules: ip6tables -L INPUT -v -n"
    echo -e "For each port which does not have a firewall rule established: ip6tables -A INPUT -p <protocol> --dport <port> -m state --state NEW -j ACCEPT"

    #3.5.3 Ensure iptables is installed
    if [[ ! $(dpkg -s iptables | grep -i status) =~ "Status: install ok installed" ]]
    then
        apt-get install iptables
    fi

    #3.6 Ensure wireless interfaces are disabled
    #Not necessary
    #iwconfig to determine wireless interfaces on system
    #ip link show up to verify wireless interfaces are active
    #ip link set <interface> down

    #3.7 Disable IPv6 
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/g' /etc/default/grub
    update-grub
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