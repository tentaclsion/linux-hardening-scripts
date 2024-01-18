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

output="$(ip6tables -L | grep Chain)"
if [ -z "${output}" ]; then
        exit $XCCDF_RESULT_FAIL
fi

while read line; do

	chain="$(echo $line | awk '{print $1, $2}')"
	policy="$(echo $line | awk '{print $4}' | tr -d ")")"
	if [ "$chain" = "Chain INPUT" ] || [ "$chain" = "Chain FORWARD" ] ||
	   [ "$chain" = "Chain OUTPUT" ]; then
		if [ "$policy" != "DROP" ] && [ "$policy" != "REJECT" ]; then
			exit $XCCDF_RESULT_FAIL
		fi
	fi

done <<< "$output"

exit $XCCDF_RESULT_PASS
