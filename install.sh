#!/bin/bash

set -e
sudo -v

function import_dir {
    local path=$1
    for SCRIPT in $path/*; do
        . $SCRIPT
    done
}

function install_zsh {
    sudo apt install -y zsh curl

    # Remove 'exec zsh -l' command in a script not to enter zsh after installing
    bash -c "$(echo "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" | sed -E 's/exec zsh -l//')"

    # Donwload powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    install_config ${BASE_PATH}/config/zsh/zshrc ~/.zshrc
    install_config ${BASE_PATH}/config/zsh/p10k.zsh ~/.p10k.zsh
}

function install {
    source /etc/lsb-release
    source /etc/os-release

    if [[ $EUID -eq 0 ]]; then
        echo -e "${ERROR}This script must be ran as non-root. But needs sudoer for some commands.${END}"
        exit 0
    fi

    echo -e "Your OS : \033[32m$DISTRIB_DESCRIPTION\033[0m"

    if [[ ${DISTRIB_CODENAME} = "bionic" || ${DISTRIB_CODENAME} = "focal" ]]; then
        :
    else
        echo -e "${ERROR}FAIL, CHECK your OS Version. 18.04, 20.04 is supported only${END}"
        exit 0
    fi

    if grep -qEi "(Microsoft|microsoft|WSL)" /proc/version &>/dev/null; then
        :
    fi

    # Change ubuntu repository mirror
    backup /etc/apt/sources.list
    replace_string /etc/apt/sources.list "archive.ubuntu.com" ${UBUNTU_MIRROR}
    replace_string /etc/apt/sources.list "security.ubuntu.com" ${UBUNTU_MIRROR}

    # Install configuration files
    install_config ${BASE_PATH}/config/git/gitconfig ~/.gitconfig

    # Create NEW ssh key
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
    fi

    sudo dpkg --add-architecture i386

    # Apt update and upgrade
    run sudo apt update
    run sudo apt -y upgrade

    # Install apt pacakges
    install_apt "${BASE_PATH}/asset/packages.list"

    # Install fonts
    install_apt "${BASE_PATH}/asset/fonts.list"
}

BASE_PATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
. ${BASE_PATH}/SETTING

import_dir ${BASE_PATH}/scripts

install
install_zsh
