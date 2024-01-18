#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

output="$(iptables -L | grep Chain)"
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
