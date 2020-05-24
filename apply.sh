#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath $(dirname ${BASH_SOURCE[0]}))"
source "./src/common.sh"

configPath="./config.env"
tempFolder="./tmp"
aptDependencies="curl gettext-base git caddy"

function main {
    create-temp-folder
    load-config

    ensure-sudo

    install-apt-repositories \
        "deb [trusted=yes] https://apt.fury.io/caddy/ /"

    install-apt-packages \
        curl gettext-base git caddy

    install-netdata
    install-ourcraft
    configure-caddy

    destroy-temp-folder
}

function create-temp-folder {
    sudo mkdir -p "$tempFolder"
    sudo chown -R $(whoami) "$tempFolder"
}

function destroy-temp-folder {
    sudo rm -rf "$tempFolder"
}

function install-apt-repositories {
    log-title "Installing required apt repositories"
    printf " - %s\n" "$@"
    printf "%s\n" "$@" > "${tempFolder}/srkbz.list"
    sudo mv "${tempFolder}/srkbz.list" /etc/apt/sources.list.d/srkbz.list
    sudo chown root:root /etc/apt/sources.list.d/srkbz.list
    run-silent sudo apt-get update
}

function install-apt-packages {
    log-title "Installing required apt packages"
    printf " - %s\n" $@
    run-silent sudo apt-get install -y $@
}

function install-netdata {
    log-title "Installing netdata"
    run-silent sudo bash -c 'bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --stable-channel --accept'
}

function install-ourcraft {(
    log-title "Installing ourcraft"
    cd /usr/local/src
    if [ ! -d "./ourcraft" ]; then
        run-silent sudo git clone https://github.com/sirikon/ourcraft.git
    fi
    cd ./ourcraft
    run-silent sudo git pull
    run-silent sudo ./install.sh
)}

function configure-caddy {
    log-title "Configuring Caddy"
    envsubst < ./assets/caddyfile.base > "${tempFolder}/Caddyfile"
    sudo mv "${tempFolder}/Caddyfile" /etc/caddy/Caddyfile
    sudo chown root:root /etc/caddy/Caddyfile
    run-silent systemctl reload caddy
    printf "\n"
}

function load-config {
	if [ ! -f "$configPath" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export $(cat ${configPath} | xargs)
}

main "$@"
