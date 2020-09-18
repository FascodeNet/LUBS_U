#!/usr/bin/env bash
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2020 Fascode Network.
#

set -e -u


# Default value
# Default value
# All values can be changed by arguments.
username="liveuser"


# Parse arguments
while getopts 'u:' arg; do
    case "${arg}" in
        u) username="${OPTARG}" ;;
    esac
done