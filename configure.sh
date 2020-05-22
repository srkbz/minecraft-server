#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(realpath $(dirname ${BASH_SOURCE[0]}))"
cd $SCRIPT_ROOT

configPath="${SCRIPT_ROOT}/config.env"

printf "Machine domain: "
read -r domain

printf "Monitoring password: "
read -rs monitoringPassword
printf "\n"

monitoringPasswordHash=$(htpasswd -bnBC 6 "" "${monitoringPassword}" | tr -d ':\n' | base64 | tr -d '\n')

printf "%s=%s\n" "DOMAIN" $domain "MONITORING_PASSWORD_HASH" $monitoringPasswordHash > $configPath
