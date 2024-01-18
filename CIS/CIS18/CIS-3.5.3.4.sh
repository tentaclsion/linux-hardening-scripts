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

# Check if there are base chains
nft list ruleset | awk '/hook input/,/}/' | grep 'iif "lo" accept' &>/dev/null &&\
    nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr' &>/dev/null &&\
    nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr' &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
