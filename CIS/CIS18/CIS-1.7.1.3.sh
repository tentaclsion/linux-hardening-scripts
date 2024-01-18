#!/bin/bash
#
# "Copyright 2020 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# If apparmor or apparmor-utils are not installed, then this test fails.
dpkg -s apparmor | grep -w "^Status: install ok installed" &&\
    dpkg -s apparmor-utils | grep -w "^Status: install ok installed"
if [ $? -ne 0 ]; then
        exit ${XCCDF_RESULT_FAIL}
fi

loaded_profiles=$(/usr/sbin/aa-status --profiled)
enforced_profiles=$(/usr/sbin/aa-status --enforced)
complain=$(/usr/sbin/aa-status --complaining)
if [ ${loaded_profiles} -ne $((${enforced_profiles} + ${complain})) ]; then
	exit $XCCDF_RESULT_FAIL
fi

unconfined=$(/usr/sbin/aa-status | grep "processes are unconfined" | awk '{print $1;}')
if [ $unconfined -ne 0 ]; then
	exit $XCCDF_RESULT_FAIL
fi

exit $XCCDF_RESULT_PASS
