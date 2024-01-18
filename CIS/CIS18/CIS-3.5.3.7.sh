#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# If nftables is not installed, then rule passes anyway
dpkg -s nftables | grep -w "^Status: install ok installed" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_PASS}
fi

# Check if nftables is enabled
systemctl is-enabled nftables &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
