#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# If ufw is not active, then rule passes anyway
ufw status | grep -w "Status: active" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_PASS}
fi

# if ufw is enabled, check for loopback traffic rule

# 1st for IPv4

# IPv4 rules must be the first ones after the header
lnum=$(($(ufw status verbose | grep -nw "^To" | cut -d: -f1)+2))
ufw status verbose | tail -n+${lnum} |&\
    egrep -zq "^Anywhere on lo\s+ALLOW IN\s+Anywhere[[:space:]]+Anywhere\s+DENY IN\s+127.0.0.0/8"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# then for IPv6

# Also must be the first IPv6 rules
ufw status verbose | egrep "(v6)" |&\
    egrep -zo "^Anywhere \(v6\) on lo\s+ALLOW IN\s+Anywhere \(v6\)[[:space:]]+Anywhere \(v6\)\s+DENY IN\s+::1"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
