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

# Check if default policy is drop
nft list ruleset |& grep 'hook input' |& grep -w 'policy drop' &>/dev/null &&\
    nft list ruleset |& grep 'hook forward'|&  grep -w 'policy drop' &>/dev/null &&\
    nft list ruleset |& grep 'hook output' |& grep -w 'policy drop' &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
