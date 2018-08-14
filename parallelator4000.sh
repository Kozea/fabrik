#!/bin/bash

#==============================================================================
# FILE : parallelator4000.sh
# USAGE : maj.sh configfile
# DESCRIPTION : Update computers
# NOTES :
#==============================================================================

set -e

source "$1"

function update {
    echo "Updating..."
    pacman -Syu --noconfirm || exit $?
    echo "Update done"
}

function clean {
    echo "Cleaning..."
    pacman -Rsn "$(pacman -Qdtq)" --noconfirm || exit $?
    echo "Clean done"
}

function refresh_keys {
    echo "Refreshing keys..."
    pacman-key --refresh || exit $?
    echo "Refresh done"
}

function delete_folder {
    echo "Deleting $1..."
    rm -rf "$1" || exit $?
    echo "Delete done"
}

function ssh_connect {
    # $1 : ssh user, $2 : ssh port, $3 : hostname, $4 : function, $5 : function params
    ssh -t -p "$2" "$1"@"$3" "$(typeset -f); $4"|| exit $?
}

today=$(date +%Y-%m-%d)

cd "$LOGS_DESTINATION" && mkdir -p "$today" 

IFS=" " read -ra HOSTNAMES <<< "$HOSTNAMES_TO_UP"

for hostname in "${HOSTNAMES[@]}"
do
    (
        logfile="$LOGS_DESTINATION/$today/$hostname"
        script -a -c "$(typeset -f); ssh_connect $SSH_USER $SSH_PORT $hostname $2 $OPTIONS" "$logfile"
    ) &
done
wait
