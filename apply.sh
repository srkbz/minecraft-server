#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(realpath $(dirname ${BASH_SOURCE[0]}))"
cd $SCRIPT_ROOT

configPath="${SCRIPT_ROOT}/config.env"
tempFolder="/tmp/minecraft-server-apply"
aptDependencies="apache2-utils curl gettext-base git caddy"

function main {
    sudo mkdir -p "$tempFolder"
    sudo chown -R $(whoami) "$tempFolder"
    load-config

    printf "Ensuring sudo access\n"
    sudo -v
    printf "\n"

    printf "Installing apt repositories:\n"
    sudo sh -c 'printf "deb [trusted=yes] https://apt.fury.io/caddy/ /\n" > /etc/apt/sources.list.d/caddy-fury.list'
    sudo apt-get update
    printf "\n"
    
    printf "Installing required apt packages:\n"
    printf " - %s\n" $aptDependencies
    printf "\n"
    sudo apt-get install -y $aptDependencies
    printf "\n"

    printf "Installing netdata:\n"
    sudo bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --stable-channel
    printf "\n"

    printf "Configuring Caddy:\n"
    envsubst < ./assets/caddyfile.base > "${tempFolder}/Caddyfile"
    sudo mv "${tempFolder}/Caddyfile" /etc/caddy/Caddyfile
    sudo chown root:root /etc/caddy/Caddyfile
    systemctl reload caddy
    printf "\n"
    sudo rm -rf "$tempFolder"
}

function load-config {
	if [ ! -f "$configPath" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export $(cat ${configPath} | xargs)
}

main "$@"
