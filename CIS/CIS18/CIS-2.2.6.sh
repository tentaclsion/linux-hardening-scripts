#!/bin/bash
#
# "Copyright 2019-2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

if [ "$(systemctl is-enabled slapd)" == "enabled" ]; then
    exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
