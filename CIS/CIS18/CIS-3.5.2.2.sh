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

# if ufw is enabled, check for the default policy
ufw status verbose |\
    egrep -q "^Default:\s+deny\s+\(incoming\),\s+deny\s+\(outgoing\),\s+(disabled|deny)\s+\(routed\)"
if [ $? -ne 0 ]; then
    exit ${XCCDF_RESULT_FAIL}
fi

exit ${XCCDF_RESULT_PASS}
