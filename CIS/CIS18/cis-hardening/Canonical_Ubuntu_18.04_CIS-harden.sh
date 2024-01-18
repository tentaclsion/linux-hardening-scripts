#!/bin/bash
#
# "Copyright 2019 Canonical Limited. All rights reserved."
#
#--------------------------------------------------------
#
#
#Prep Ubuntu 18.04 vanilla install for CIS 18.04 benchmark audit run
#This script will prepare a 18.04 Ubuntu installed system to
#run CIS audit by addressing CIS benchmark non-compliant
#configuration settings.
#
#
# See README.hardening file for instructions on how to use this script.

# Undefined variables trigger error
set -u

declare -A PROFILES=( ["lvl1_server"]=true ["lvl2_server"]=true ["lvl1_workstation"]=true ["lvl2_workstation"]=true ["custom"]=true )
RULESETS="1 2 3 4 5 6"
LOGFILE="$(basename ${0//.sh/.log})"
CURRENT_DIR=$(pwd) # Current working directory
SCRIPT_DIR=$(dirname $BASH_SOURCE) # Script directory
PARAM_FILEPATH="${SCRIPT_DIR}/ruleset-params.conf" # Path to the parameter file. Uses the one in script dir by default.

function usage
{
    local keys="${!PROFILES[@]}"
    echo "Usage: $0 [ -f <parameter file path> ] < ${keys// / | } >"
}

function rsbanner
{
    echo "################################################################################"
    echo "#                             RULESET $1                                      #"
    echo "################################################################################"
}

function profile_banner
{
    if [ $1 != "custom" ]; then
        echo "***Applying Level-${1:3:1} scored ${1:5} remediation for failures on a fresh Ubuntu 18.04 install***"
    else
        echo "***Applying custom selection of remediation rules for failures on a fresh Ubuntu 18.04 install***"
    fi
}

# Calls the subfunctions associated with rule execution, based on profile selected.
# 1st argument is the profile name (see PROFILES for valid names)
function execute_profile_rules
{
    local profile
    if [ $# -eq 0 ]; then
        profile=""
    else
        profile="$1"
    fi

    if [ $(id -u) -ne 0 ]; then
        echo "This script must be executed by the root user!"
        exit 1
    fi

    if [ ! -e "${PARAM_FILEPATH}" ]; then
        echo "Parameter file path '${PARAM_FILEPATH}' does not point to a valid file"
        exit 1
    fi

    if [ -z "$profile" ]; then
        usage
        exit 1
    fi

    # profile selected must in the list of profiles
    if [ ! ${PROFILES[$profile]} ]; then
        echo "Profile '$profile' is not valid!"
        usage
        exit 1
    fi

    profile_banner $profile

    # Moves out to script dir, since script modules expect that dir. If required, the directory where the script is executed
    # from is in the CURRENT_DIR variable
    cd ${SCRIPT_DIR}

    # Stop the unattended-upgrade service while the script runs to prevent it from locking the package system.
    systemctl stop unattended-upgrades.service

    # Update the apt database since some rules will fail if you don't.
    apt-get update

    for ruleset in $RULESETS; do
        local rsfile="./CIS-ruleset-$ruleset"".sh"
        source $rsfile
        rsbanner $ruleset
        eval "execute_ruleset-$ruleset" $profile
    done

    systemctl start unattended-upgrades.service
}

######### Main execution #########

# Handle command parameters
while getopts ":f:" opts; do
    case ${opts} in
    f)
        PARAM_FILEPATH="${OPTARG}"
        ;;
    *)
        if [ "${opts}" == ":" ]; then
            echo "-${OPTARG} flag requires a parameter"
        else
            echo "Wrong parameter -${OPTARG}"
        fi
        usage
        exit 1
        ;;
    esac
done

shift $((OPTIND-1))

# If no parameters passed, send empty string to function
if [ $# -eq 0 ]; then
    PARAM_PROFILE=""
else
    PARAM_PROFILE="$1"
fi

# Calls routine which handles specific rules
execute_profile_rules "${PARAM_PROFILE}" 2>&1 | tee "${CURRENT_DIR}/${LOGFILE}"
