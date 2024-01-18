#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------

# Global constants
LOGINDEFS_FILE=/etc/login.defs
BASHRC_FILE=/etc/bash.bashrc
PROFILE_FILE=/etc/profile

# Global patterns for printf
LIMITSD_PAT_PATH='/etc/security/limits.d/Canonical_Ubuntu_CIS_%s.conf'
MODPROB_PAT_PATH='/etc/modprobe.d/Canonical_Ubuntu_CIS_%s.conf'
SYSCTLD_PAT_PATH='/etc/sysctl.d/40-Canonical_Ubuntu_CIS_%s.conf'
SUDO_PAT_PATH='/etc/sudoers.d/40-Canonical_Ubuntu_CIS_%s.conf'
PROFILED_PAT_PATH='/etc/profile.d/Canonical_Ubuntu_CIS_%s.sh'

# Verify if PARAM_FILEPATH var is not empty, otherwise use a default value
# this is mostly to allow debug of individual modules
if [ ! -v PARAM_FILEPATH ] || [ -z "${PARAM_FILEPATH}" ]; then
    PARAM_FILEPATH=$(dirname ${BASH_SOURCE})/ruleset-params.conf
fi


# Based on argument, effectively calls the functions responsible for each rule
# This is used by the sourced files
function do_execute_rules()
{
    local rset=$@

    if [ -z "${rset}" ]; then
        echo "***No rules found! Skipping this section!***"
        return
    fi

    rset=$(echo -n "${rset}"  | tr -s ' ' '\n' | sort -V -u | tr '\n' ' ')

    echo -e "***List of rules to be executed: ${rset}\n"

    for rule in ${rset}; do
        echo "Execute rule $rule"
        if [ "$(type -t rule-$rule)" != function ]; then
            exec_error "$rule" "function not found!"
        fi
        rule-$rule
    done
}

function exec_error()
{
    local rulenum="$1"
    shift 1
    if [ $# -gt 0 ]; then
        echo "Error executing rule $rulenum - $@"
    else
        echo "Error executing rule $rulenum"
    fi
    exit 1
}

# Grabs parameters configured by the script user.
# IF parameter doesn't exist, return empty string.
function read_usr_param()
{
    # If CURRENT_DIR var exists, move there, since the path to the parameter file
    # can be a relative one.
    test -v CURRENT_DIR && pushd ${CURRENT_DIR} &>/dev/null

    sed '/^#.*/D' "${PARAM_FILEPATH}" | grep "$1=" | cut -d= -f2 | tr -d '\n'

    test -v CURRENT_DIR && popd &>/dev/null
} 

# Grabs list of rules to be executed according to the ruleset
# which is passed as the 1st parameter.
# If the list of rules doesn't exist or is invalid, return empty string.
# The rules must be inside double quotes and the list can span more than
# one line.
function read_rules_list()
{
    local ruleset="ruleset$1"

    # If CURRENT_DIR var exists, move there, since the path to the parameter file
    # can be a relative one.
    test -v CURRENT_DIR && test -n "${CURRENT_DIR}" && pushd ${CURRENT_DIR} &>/dev/null

    # Extract list of rules based on section number parameter provided
    grep -Po "(?<=^${ruleset}=\")(\s*(\d+\.)*\d+)+(?=\"\$)" ${PARAM_FILEPATH}

    test -v CURRENT_DIR && test -n "${CURRENT_DIR}" && popd &>/dev/null
}

# Prints rule banner
function print_rule_banner()
{
    echo
    echo "$@"
}

function print_manual_req_msg()
{
    echo "$@"" - requires manual configuration"
}

function print_error_msg()
{
    echo "Error on $(get_rule_tag): $@"
}

# Print function name "rule-<rule number> when executed from a function
#with "rule-<rule number>" name pattern.
# Exits with an error if no "rule-<rule number>" pattern exists in the call stack!
function get_rule_tag()
{
    local ruletag=
    for func in ${FUNCNAME[@]}; do
        ruletag=$(echo -n "$func" | grep -P "^rule-(\d+\.?)+$")
        if [ -n "${ruletag}" ]; then
            echo -n "${ruletag}"
            return
        fi
    done

    exec_error "No rule number found in the call stack!"
}
        
# Verify if a package is installed
function is_installed()
{
    local pkgname=$1

    if [ -z "${pkgname}" ]; then
        return 1
    fi
    dpkg -s -- ${pkgname} 2>/dev/null | grep -qw installed
}

function add_kernel_boot_param()
{
    local param_to_add="$1"
    local param_to_add_val="$2"
    local grub_cfg=/etc/default/grub

    if [ -z "${param_to_add}" ]; then
        exec_error "No parameter added to ${FUNCNAME}"
        return
    fi

    local cur_param=$(grep -Po "(?<=^GRUB_CMDLINE_LINUX=\")[^\"]*" ${grub_cfg})
    if [ $? -eq 0 ]; then
        # Remove old param, if it exist
        tmp_vec=($(echo "${cur_param}" | sed -E "s/\b${param_to_add}\b(=\S+)?//"))

        # And add new param
        if [ -z "${param_to_add_val}" ]; then
            tmp_vec+=("${param_to_add}")
        else
            tmp_vec+=("${param_to_add}=${param_to_add_val}")
        fi

        cur_param="${tmp_vec[@]}"
        # Remove old GRUB_CMDLINE_LINUX entry
        sed -i /^GRUB_CMDLINE_LINUX=/d ${grub_cfg}
    fi

    echo "GRUB_CMDLINE_LINUX=\"${cur_param}\"" >> ${grub_cfg}
}

# Execute update grub and fix permissions changed
function do_update_grub()
{
    local cfg="/boot/grub/grub.cfg"
    update-grub
    chown root:root $cfg
    chmod og-rwx $cfg
}

# Disable a module by removing it and blocking module load on modprobe.d
# module name is passed as 1st parameter
disable_mod()
{
    local modname=$1
    local outfile="$(printf ${MODPROB_PAT_PATH} $(get_rule_tag))"

    echo "install ${modname} /bin/true" > ${outfile}

    lsmod | grep -q -w "${modname}" && rmmod "${modname}"
}
