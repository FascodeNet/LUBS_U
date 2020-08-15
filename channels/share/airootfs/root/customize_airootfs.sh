#!/usr/bin/env bash

set -e

# Default value
# All values can be changed by arguments.

password="liveuser"
username="liveuser"
usershell="/bin/bash"
debug=true

# Parse arguments
while getopts 'p:u:s:dxa:' arg; do
    case "${arg}" in
        p) password="${OPTARG}" ;;
        u) username="${OPTARG}" ;;
        s) usershell="${OPTARG}" ;;
        d) debug=true ;;
        x) debug=true; set -xv ;;
        a) arch="${OPTARG}"
    esac
done


# Creating a root user.
# usermod -s /usr/bin/zsh root
function user_check () {
if [[ $(getent passwd $1 > /dev/null ; printf $?) = 0 ]]; then
    if [[ -z $1 ]]; then
        echo -n "false"
    fi
    echo -n "true"
else
    echo -n "false"
fi
}

if [[ $(user_check root) = false ]]; then
    usermod -s "${usershell}" root
    cp -aT /etc/skel/ /root/
    chmod 700 /root
    LC_ALL=C LANG=C xdg-user-dirs-update
fi
echo -e "${password}\n${password}" | passwd root

# Allow sudo group to run sudo
sed -i 's/^#\s*\(%sudo\s\+ALL=(ALL)\s\+ALL\)/\1/' /etc/sudoers

# Create a user.
# create_user <username> <password>
function create_user () {
    local _password
    local _username

    _username=${1}
    _password=${2}

    set +u
    if [[ -z "${_username}" ]]; then
        echo "User name is not specified." >&2
        return 1
    fi
    if [[ -z "${_password}" ]]; then
        echo "No password has been specified." >&2
        return 1
    fi
    set -u

    if [[ $(user_check ${_username}) = false ]]; then
        useradd -m -s ${usershell} ${_username}
        usermod -U -g ${_username} ${_username}
        usermod -aG sudo ${_username}
        usermod -aG storage ${_username}
        cp -aT /etc/skel/ /home/${_username}/
    fi
    chmod 700 -R /home/${_username}
    chown ${_username}:${_username} -R /home/${_username}
    echo -e "${_password}\n${_password}" | passwd ${_username}
    set -u
}

create_user "${username}" "${password}"


# Set up auto login
if [[ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]]; then
    sed -i s/%USERNAME%/"${username}"/g /etc/systemd/system/getty@tty1.service.d/autologin.conf
fi


# Set to execute calamares without password as alter user.
cat >> /etc/sudoers << "EOF"
Defaults pwfeedback
EOF
echo "${username} ALL=NOPASSWD: ALL" >> /etc/sudoers.d/alterlive


# Chnage sudoers permission
chmod 750 -R /etc/sudoers.d/
chown root:root -R /etc/sudoers.d/