#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# Pass rule if IPv6 is disabled on kernel
grep -wq "ipv6.disable=1" /proc/cmdline
if [ $? -eq 0 ]; then
    exit $XCCDF_RESULT_PASS
fi

# Check chain INPUT for loopback related rules
ip6tables -L INPUT -v -n |\
    egrep -z "\s+[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+lo\s+\*\s+::/0\s+::/0[[:space:]]+[0-9]+\s+[0-9]+\s+DROP\s+all\s+\*\s+\*\s+::1\s+::/0"
if [ $? -ne 0 ]; then
    exit $XCCDF_RESULT_FAIL
fi

# Check chain OUTPUT for loopback related rules
ip6tables -L OUTPUT -v -n |\
    egrep "\s[0-9]+\s+[0-9]+\s+ACCEPT\s+all\s+\*\s+lo\s+::/0\s+::/0"
if [ $? -ne 0 ]; then
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
