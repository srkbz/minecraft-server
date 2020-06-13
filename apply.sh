#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath $(dirname ${BASH_SOURCE[0]}))"
source "./src/common.sh"

configPath="./config.env"
aptDependencies="curl gettext-base git caddy"

function main {
    load-config

    install-apt-repositories \
        "deb [trusted=yes] https://apt.fury.io/caddy/ /"

    install-apt-packages \
        curl gettext-base git caddy jq

    install-netdata
    install-ourcraft

    apply-ufw \
        "default allow outgoing" \
        "default deny incoming" \
        "allow in 22 comment SSH" \
        "allow in 80 comment Caddy-HTTP" \
        "allow in 443 comment Caddy-HTTPS" \
        "allow in 25565 comment Minecraft" \

    configure-caddy

    create-ourcraft-user
}

function install-apt-repositories {
    log-title "Installing required apt repositories"
    printf " - %s\n" "$@"
    printf "%s\n" "$@" > "/etc/apt/sources.list.d/srkbz.list"
    run-silent apt-get update
}

function install-apt-packages {
    log-title "Installing required apt packages"
    printf " - %s\n" $@
    run-silent apt-get install -y $@
}

function install-netdata {
    log-title "Installing netdata"
    run-silent bash -c 'bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --stable-channel --accept'
}

function install-ourcraft {
    log-title "Installing ourcraft"
    run-silent bash -c 'curl -s https://raw.githubusercontent.com/sirikon/ourcraft-installer/master/install.sh | bash'
}

function apply-ufw {(
    log-title "Installing UFW configuration"
    run-silent ufw --force reset
    rm /etc/ufw/*rules.*
    for rule in "$@"
    do
        run-silent ufw $rule
    done
    run-silent ufw --force enable
)}

function configure-caddy {
    log-title "Configuring Caddy"
    envsubst < ./assets/caddyfile.base > "/etc/caddy/Caddyfile"
    run-silent systemctl reload caddy
    printf "\n"
}

function create-ourcraft-user {
    username="ourcraft"
    getent group "${username}" &>/dev/null || groupadd "${username}"
    id -u "${username}" &>/dev/null || useradd \
        --gid "${username}" \
        --create-home \
        --shell /usr/bin/bash \
        "${username}"
    loginctl enable-linger "${username}"

    mkdir -p ~ourcraft/.ssh
    (
        cd ~ourcraft/.ssh
        cp ~/.ssh/authorized_keys .
        chown -R "${username}:${username}" ~ourcraft/.ssh
        chmod +r ~ourcraft/.ssh/authorized_keys
    )
}

function load-config {
	if [ ! -f "$configPath" ]; then
		printf "Config file is missing\n"
		exit 1
	fi
	export $(cat ${configPath} | xargs)
}

main "$@"
