#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# If nftables is not installed or not enabled, then rule passes anyway
dpkg -s nftables | grep -w "^Status: install ok installed" &>/dev/null &&\
    systemctl is-enabled nftables &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_PASS}
fi

# Check rules in input chain
filename="/etc/nftables.conf"

in_regexp="chain input {[^}]+}"
egrep -zo "${in_regexp}" ${filename} | egrep -zqw "policy drop" &&\
    egrep -zo "${in_regexp}" ${filename} | egrep -zqw "iif \"lo\" accept" &&\
    egrep -zo "${in_regexp}" ${filename} | egrep -zqw "ip saddr 127.0.0.0/8" &&\
    egrep -zo "${in_regexp}" ${filename} | egrep -zqw "ip6 saddr ::1"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

out_regexp="chain output {[^}]+}"
egrep -zo "${out_regexp}" ${filename} | egrep -zqw "policy drop"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

fwd_regexp="chain forward {[^}]+}"
egrep -zo "${fwd_regexp}" ${filename} | egrep -zqw "policy drop"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
