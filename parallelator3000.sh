#!/bin/bash

set -e

source $1

function read_news {
    echo "Read news"
    sudo eselect news read
}

function update_server {
    echo "Update server"
    sudo emerge -DNautq --keep-going --with-bdeps=y --quiet-build @world
}

function update_config {
    echo "Update config"
    sudo dispatch-conf
}

function compile_packages {
    echo "Compile packages"
    sudo revdep-rebuild -q -- -avq1
}

function compile_preserved_packages {
    echo "Compile preserved packages"
    sudo emerge -aq --keep-going @preserved-rebuild
}

function clean_server {
    echo "Clean server"
    sudo emerge -avq --depclean
}

function update {
    echo "Update starts"
    read_news || exit $?
    update_server || exit $?
    update_config || exit $?
    compile_packages || exit $?
    compile_preserved_packages || exit $?
    clean_server || exit $?
    echo "Update ends"
}

function ssh_connect {
    ssh -t -p $PORT $USER_P3000@$1$DOMAIN "$(typeset -f); $2"
}

IFS=" " read -ra SERVERS_NAME <<< "$SERVERS"
for server_name in "${SERVERS_NAME[@]}"; do
   echo "########### $server_name ###########"
   screen -L -D -m -S $server_name bash -c "$(typeset); ssh_connect $server_name $2" &
   $TERM_NEW $TERM_EXE_CMD="screen -r $server_name" $TERM_TITLE="$server_name"
done

