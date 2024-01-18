#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

. ./ruleset-tools.sh

# Global vars

########################## SUPPORT FUNCTIONS #################################

# Return user name and their respective home directory, separated by a single " "
fetch_users_and_homedir()
{
    cat /etc/passwd | egrep -v '^(halt|sync|shutdown)' |\
     awk -F: '($7 != "/usr/sbin/nologin" && $7 != "/bin/false" && $3 >= 1000)\
     { print $1 " " $6 }'
}

########################## RULE FUNCTIONS #################################

#6.1.1 Audit system file permissions (Manual)
rule-6.1.1()
{
    local banner="Audit system file permissions"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#6.1.2 Ensure permissions on /etc/passwd are configured (Automated)
rule-6.1.2()
{
    print_rule_banner "Ensure permissions on /etc/passwd are configured"
    chown root:root /etc/passwd
    chmod 644 /etc/passwd
}

#6.1.3 Ensure permissions on /etc/gshadow- are configured (Automated)
rule-6.1.3()
{
    print_rule_banner "Ensure permissions on /etc/gshadow- are configured"
    chown root:shadow /etc/gshadow-
    chmod o-rwx,g-wx,u-x /etc/gshadow-
}

#6.1.4 Ensure permissions on /etc/shadow are configured (Automated)
rule-6.1.4()
{
    print_rule_banner "Ensure permissions on /etc/shadow are configured"
    chown root:shadow /etc/shadow
    chmod u-x,o-rwx,g-wx /etc/shadow
}

#6.1.5 Ensure permissions on /etc/group are configured (Automated)
rule-6.1.5()
{
    print_rule_banner "Ensure permissions on /etc/group are configured"
    chown root:root /etc/group
    chmod 644 /etc/group
}

#6.1.6 Ensure permissions on /etc/passwd- are configured (Automated)
rule-6.1.6()
{
    print_rule_banner "Ensure permissions on /etc/passwd- are configured"
    chown root:root /etc/passwd-
    chmod u-x,go-rwx /etc/passwd-
}

#6.1.7 Ensure permissions on /etc/shadow- are configured (Automated)
rule-6.1.7()
{
    print_rule_banner "Ensure permissions on /etc/shadow- are configured"
    chown root:shadow /etc/shadow-
    chmod u-x,g-wx,o-rwx /etc/shadow-
}

#6.1.8 Ensure permissions on /etc/group- are configured (Automated)
rule-6.1.8()
{
    print_rule_banner "Ensure permissions on /etc/group- are configured"
    chown root:root /etc/group-
    chmod u-x,go-wx /etc/group-
}

#6.1.9 Ensure permissions on /etc/gshadow are configured (Automated)
rule-6.1.9()
{
    print_rule_banner "Ensure permissions on /etc/gshadow are configured"
    chown root:shadow /etc/gshadow
    chmod u-x,o-rwx,g-wx /etc/gshadow
}

#6.1.10 Ensure no world writable files exist (Automated)
rule-6.1.10()
{
    print_rule_banner "Ensure no world writable files exist"
    df --local -P | awk {'if (NR!=1) print $6'} | while read mnt; do
        find ${mnt} -xdev -type f -perm -0002 -execdir chmod o-w '{}' \; 2>/dev/null
    done
}

#6.1.11 Ensure no unowned files or directories exist (Automated)
rule-6.1.11()
{
    local banner="Ensure no unowned files or directories exist"
    print_rule_banner ${banner}
    local user=$(read_usr_param unowned_user)
    if [ -n "${user}" ]; then
        df --local -P | awk {'if (NR!=1) print $6'} | while read mnt; do
            find ${mnt} -xdev -nouser -execdir chown ${user} '{}' \; 2>/dev/null
        done
    else
        print_manual_req_msg ${banner}
    fi
}

#6.1.12 Ensure no ungrouped files or directories exist (Automated)
rule-6.1.12()
{
    local banner="Ensure no ungrouped files or directories exist"
    print_rule_banner ${banner}
    local group=$(read_usr_param unowned_group)
    if [ -n "${group}" ]; then
        df --local -P | awk {'if (NR!=1) print $6'} | while read mnt; do
            find ${mnt} -xdev -nogroup -execdir chown :${group} '{}' \; 2>/dev/null
        done
    else
        print_manual_req_msg ${banner}
    fi
}

#6.1.13 Audit SUID executables (Manual)
rule-6.1.13()
{
    local banner="Audit SUID executables"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#6.1.14 Audit SGID executables (Manual)
rule-6.1.14()
{
    local banner="Audit SGID executables"
    print_rule_banner ${banner}
    print_manual_req_msg ${banner}
}

#6.2.1 Ensure password fields are not empty (Automated)
rule-6.2.1()
{
    print_rule_banner "Ensure password fields are not empty"
    for usr in $(cat /etc/shadow | awk -F: '($2 == "" ) { print $1 }'); do
        passwd -l ${usr}
    done
}

#6.2.2 Ensure root is the only UID 0 account (Automated)
rule-6.2.2()
{
    print_rule_banner "Ensure root is the only UID 0 account"
    local uid0_usr=$(grep -v '^root:' /etc/passwd |\
        awk -F: '($3 == 0) { print $1 }')
    for usr in $uid0_usr; do
        sed -i "/^${usr}:/D" /etc/passwd
    done
}

#6.2.3 Ensure root PATH Integrity (Automated - only warns, not fix)
rule-6.2.3()
{
    local banner="Ensure root PATH Integrity"
    print_rule_banner ${banner}

    local issue_found=0
    if [ -n "$(echo $PATH | grep :: )" ]; then
       echo "Empty Directory in PATH (::)"
       issue_found=1
    fi

    if [ -n "$(echo $PATH | grep :$)" ]; then
        echo "Trailing : in PATH"
        issue_found=1
    fi

    # Split PATH variable into several variables
    IFS=: read -a path_toks <<< "$PATH"

    for p_tok in "${path_toks[@]}"; do
        if [ "${p_tok}" = "." ]; then
            echo "PATH contains ."
            issue_found=1
            continue
        fi
        if [ -d "${p_tok}" ]; then
            dirperm=$(stat -c %A "${p_tok}")
            if [ "$(echo $dirperm | cut -c6 )" != "-" ]; then
                issue_found=1
                echo "Group Write permission set on directory ${p_tok}"
            fi
            if [ "$(echo $dirperm | cut -c9 )" != "-" ]; then
                issue_found=1
                echo "Other Write permission set on directory ${p_tok}"
            fi
            dirown=$(stat -c %U "${p_tok}")
            if [ "${dirown}" != "root" ] ; then
                echo "${p_tok} is not owned by root"
                issue_found=1
            fi
        else
            echo "${p_tok} is not a directory"
            issue_found=1
        fi
    done

    if [ "${issue_found}" -eq 1 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.4 Ensure all users' home directories exist (Automated)
rule-6.2.4()
{
    print_rule_banner "Ensure all users' home directories exist"

    fetch_users_and_homedir |\
    while read user dir; do
        pushd /
        mkdir -p ${dir}
        chown ${user}:${user} ${dir}
        popd
    done
}

#6.2.5 Ensure users' home directories permissions are 750 or more restrictive (Automated)
rule-6.2.5()
{
    local adduser_conf=/etc/adduser.conf
    local useradd_conf=/etc/login.defs

    print_rule_banner "Ensure users' home directories permissions are 750 or more restrictive"

    fetch_users_and_homedir |\
    while read user dir; do
        chmod o-wrx,g-w ${dir}
    done

    # For users added through adduser
    local v=$(grep -Po '(?<=^DIR_MODE=)\d?\d{3}' ${adduser_conf})
    if [ -n "${v}" ]; then
        # check if num passes valid mask
        if [ $((0${v} & 07027)) -ne 0 ]; then
            sed -E -i 's/(^DIR_MODE=).*$/\10750/g' ${adduser_conf}
        fi
    else
        echo 'DIR_MODE=0750' >> ${adduser_conf}
    fi

    # For users added through useradd
    v=$(grep -Po '(?<=^UMASK\b)' ${useradd_conf} | sed -E s/^\s+//)
    if [ -n "${v}" ]; then
        # check if num passes valid mask
        if [ $((0${v} & 00750)) -ne 0 ]; then
            sed -E -i 's/(^UMASK\s+).*$/\1027/g' ${useradd_conf}
        fi
    else
        echo 'UMASK           027' >> ${useradd_conf}
    fi
}

#6.2.6 Ensure users own their home directories (Automated)
rule-6.2.6()
{
    print_rule_banner "Ensure users own their home directories"
    
    fetch_users_and_homedir |\
    while read user dir; do
        chown ${user} ${dir}
    done
}

#6.2.7 Ensure users' dot files are not group or world writable (Automated)
rule-6.2.7()
{
    print_rule_banner "Ensure users' dot files are not group or world writable"

    fetch_users_and_homedir |\
    while read user dir; do
        find ${dir} -iname '.*' -type f -execdir chmod o-w,g-w {} \;
    done
}

#6.2.8 Ensure no users have .forward files (Automated)
rule-6.2.8()
{
    local banner="Ensure no users have .forward files"
    local found=0
    local del_files=$(read_usr_param delete_user_files)

    print_rule_banner ${banner}

    fetch_users_and_homedir |\
    while read user dir; do
        if [ -f ${dir}/.forward ]; then
            if "${del_files}"; then
                rm -f ${dir}/.forward
            else
                found=1
                echo ".forward file found in ${user} homedir."
            fi
        fi
    done

    if [ ${found} -gt 0 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.9 Ensure no users have .netrc files
rule-6.2.9()
{
    local banner="Ensure no users have .netrc files"
    local found=0
    local del_files=$(read_usr_param delete_user_files)

    print_rule_banner ${banner}

    fetch_users_and_homedir |\
    while read user dir; do
        if [ -f ${dir}/.netrc ]; then
            if "${del_files}"; then
                rm -f ${dir}/.netrc
            else
                found=1
                echo ".netrc file found in ${user} homedir."
            fi
        fi
    done

    if [ ${found} -gt 0 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.10 Ensure users' .netrc Files are not group or world accessible (Automated)
rule-6.2.10()
{
    print_rule_banner "Ensure users' .netrc Files are not group or world accessible"
    fetch_users_and_homedir |\
    while read user dir; do
        chmod -f og-rwx ${dir}/.netrc
    done
}

#6.2.11 Ensure no users have .rhosts files (Automated)
rule-6.2.11()
{
    local banner="Ensure no users have .rhosts files"
    local found=0
    local del_files=$(read_usr_param delete_user_files)

    print_rule_banner ${banner}

    fetch_users_and_homedir |\
    while read user dir; do
        if [ -f ${dir}/.rhosts ]; then
            if "${del_files}"; then
                rm -f ${dir}/.rhosts
            else
                found=1
                echo ".rhosts file found in ${user} homedir."
            fi
        fi
    done

    if [ ${found} -gt 0 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.12 Ensure all groups in /etc/passwd exist in /etc/group (Automated)
rule-6.2.12()
{
    print_rule_banner "Ensure all groups in /etc/passwd exist in /etc/group"
    for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
        grep -q -P "^.*?:[^:]*:$i:" /etc/group
        if [ $? -ne 0 ]; then
            groupadd $i
        fi
    done
}

#6.2.13 Ensure no duplicate UIDs exist (Automated - only warns, not fix)
rule-6.2.13()
{
    local banner="Ensure no duplicate UIDs exist"
    print_rule_banner ${banner}

    local flag=0
    local nuid
    for uid in $(cat /etc/passwd | cut -d: -f3 | sort -u); do
        nuid=0;
        for v in $(cat /etc/passwd | cut -d: -f3); do
            if [ ${v} -eq ${uid} ]; then
                nuid=$((nuid + 1));
            fi;
        done;

        if [ ${nuid} -gt 1 ]; then
            flag=1
            echo "duplicate uid ${uid} found";
        fi;
    done


    if [ ${flag} -eq 1 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.14 Ensure no duplicate GIDs exist (Automated - only warns, not fix)
rule-6.2.14()
{
    local banner="Ensure no duplicate GIDs exist"
    print_rule_banner ${banner}

    local flag=0
    local ngid
    for gid in $(cat /etc/group | cut -d: -f3 | sort -u); do
        ngid=0;
        for v in $(cat /etc/group | cut -d: -f3); do
            if [ ${v} -eq ${gid} ]; then
                ngid=$((ngid + 1));
            fi;
        done;

        if [ ${ngid} -gt 1 ]; then
            flag=1
            echo "duplicate gid ${gid} found";
        fi;
    done

    if [ ${flag} -eq 1 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.15 Ensure no duplicate user names exist (Automated - only warns, not fix)
rule-6.2.15()
{
    local banner="Ensure no duplicate user names exist"
    print_rule_banner ${banner}

    local flag=0
    local nuser
    for user in $(cat /etc/passwd | cut -d: -f1 | sort -u); do
        nuser=0;
        for v in $(cat /etc/passwd | cut -d: -f1); do
            if [ ${v} == ${user} ]; then
                nuser=$((nuser + 1));
            fi;
        done;

        if [ ${nuser} -gt 1 ]; then
            flag=1
            echo "duplicate username ${user} found";
        fi;
    done

    if [ ${flag} -eq 1 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.16 Ensure no duplicate group names exist (Automated - only warns, not fix)
rule-6.2.16()
{
    local banner="Ensure no duplicate group names exist"
    print_rule_banner ${banner}

    local flag=0
    local ngroup
    for group in $(cat /etc/passwd | cut -d: -f1 | sort -u); do
        ngroup=0;
        for v in $(cat /etc/passwd | cut -d: -f1); do
            if [ ${v} == ${group} ]; then
                ngroup=$((ngroup+ 1));
            fi;
        done;

        if [ ${ngroup} -gt 1 ]; then
            flag=1
            echo "duplicate group name ${group} found";
        fi;
    done

    if [ ${flag} -eq 1 ]; then
        print_manual_req_msg ${banner}
    fi
}

#6.2.17 Ensure shadow group is empty (Automated - only warns, not fix)
rule-6.2.17()
{
    local banner="Ensure shadow group is empty"
    print_rule_banner ${banner}

    local shadow_gid=$(egrep "^shadow\b" /etc/group | cut -d: -f3)
    local usr_from_group=$(grep ^shadow:[^:]*:[^:]*:[^:]+ /etc/group)
    local grp_from_users=$(awk -F: '($4 == '${shadow_gid}') { print }' /etc/passwd)
    if [ -n "${usr_from_group}"  ] ||\
       [ -n "${grp_from_users}" ]; then
       echo "Shadow group is not empty!"
       print_manual_req_msg ${banner}
    fi
}

execute_ruleset-6()
{
    local -A rulehash
    local common="6.1.2 6.1.3 6.1.4 6.1.5 6.1.6 6.1.7 6.1.8 6.1.9 6.1.10\
        6.1.11 6.1.12 6.1.13 6.1.14 6.2.1 6.2.2 6.2.3 6.2.4 6.2.5 6.2.6 6.2.7\
        6.2.8 6.2.9 6.2.10 6.2.11 6.2.12 6.2.13 6.2.14 6.2.15 6.2.16 6.2.17"
    rulehash[lvl1_server]="$common"
    rulehash[lvl2_server]="${rulehash[lvl1_server]}"" 6.1.1"
    rulehash[lvl1_workstation]="$common"
    rulehash[lvl2_workstation]="${rulehash[lvl1_workstation]}"" 6.1.1"

    rulehash[custom]=$(read_rules_list 6)

    do_execute_rules ${rulehash[$1]}
}
