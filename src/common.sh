#!/usr/bin/env bash
set -euo pipefail

WHITE="\e[21m"
CYAN="\e[96m"
BLUE="\e[36m"
RED='\e[1;31m'

BOLD="\e[1m"
REGULAR="\e[0m"

RESET="${WHITE}${REGULAR}"

function log-title {
    printf "${CYAN}${BOLD}:: %s${RESET}\n" "$1"
}

function log-error {
    printf "${RED}${BOLD}:: %s${RESET}\n" "$1" >&2
}

function log {
    printf "${BLUE}:: %s${RESET}\n" "$1"
}

function log-sep {
    printf "\n"
}

function run-silent {
    set +e
    output=$("$@" 2>&1)
    result=$?
    set -e
    if [ "$result" -gt "0" ]; then
        log-error "Error while running command:"
        log-error "$*"
        printf "%s\n" "$output"
        exit "$result"
    fi
}

function ensure-dependencies {
    log-title "Ensuring apt dependencies"
    printf " - %s\n" $@
    run-silent apt-get install -y $@
}
