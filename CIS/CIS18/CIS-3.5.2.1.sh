#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# If ufw is not installed, then rule passes anyway
dpkg -s ufw | grep -w "^Status: install ok installed" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_PASS}
fi

# Check if ufw is enabled in systemd
systemctl status ufw | grep -w "Active: active" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

# Check if ufw is active
ufw status | grep -w "Status: active" &>/dev/null
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
