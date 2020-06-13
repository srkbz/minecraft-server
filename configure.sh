#!/usr/bin/env bash
set -euo pipefail
cd "$(realpath $(dirname ${BASH_SOURCE[0]}))"
source "./src/common.sh"

configPath="./config.env"

function main {
    ensure-dependencies apache2-utils
    log-sep

    ask-for "Machine domain" domain
    ask-for-password "Monitoring password" monitoringPassword

    monitoringPasswordHash=$(hash-password $monitoringPassword)

    write-config \
        "DOMAIN" $domain \
        "MONITORING_PASSWORD_HASH" $monitoringPasswordHash
}

function ask-for {
    printf "$1: "
    read -r $2
}

function ask-for-password {
    printf "$1: "
    read -rs $2
    printf "\n"
}

function hash-password {
    htpasswd -bnBC 6 "" "$1" | tr -d ':\n' | base64 | tr -d '\n'
}

function write-config {
    printf "%s=%s\n" $@ > $configPath
}

main $@
