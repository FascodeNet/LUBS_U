#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0
#
# mk-linux419
# Twitter: @fascoder_4
# Email  : m.k419sabuaka@gmail.com
#
# Yamada Hayao
# Twitter: @Hayao0819
# Email  : hayao@fascode.net
#
# (c) 2019-2020 Fascode Network.
#
# customize_airootfs_serene.sh
#

set -e -u

# Default value
# All values can be changed by arguments.
password="liveuser"
username="liveuser"
usershell="/bin/bash"
debug=true


# Parse arguments
while getopts 'p:bt:k:rxju:o:i:s:da:' arg; do
    case "${arg}" in
        p) password="${OPTARG}" ;;
        u) username="${OPTARG}" ;;
        s) usershell="${OPTARG}" ;;
        d) debug=true ;;
        x) debug=true; set -xv ;;
        a) arch="${OPTARG}"
    esac
done

# Enable LightDM to auto login
systemctl enable lightdm.service

# Replace auto login user
sed -i s/%USERNAME%/${username}/g /etc/lightdm/lightdm.conf