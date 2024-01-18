#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# Disable job control and run the last command of a pipeline in the current shell environment
# Require Bash 4.2 and later
set +m
shopt -s lastpipe

result=$XCCDF_RESULT_PASS

# get todays date in epoch
TZ=GMT
today=$(($(date +%s) / 60 / 60 /24))
cat /etc/shadow | awk -F: '{ print $1 " " $3 }' | while read user last_pwd_change; do
	if [ "$last_pwd_change" -gt "$today" ]; then
		echo "$user has a password change date in the future."
		result=$XCCDF_RESULT_FAIL
		break
	fi
done
exit $result
