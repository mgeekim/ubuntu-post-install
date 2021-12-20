function import_dir {
    local path=$1
    for SCRIPT in $path/*;
    do
        . $SCRIPT
    done
}

if [[ $EUID -eq 0 ]]; then
    echo "This script must be run as non-root. But needs sudoer for some commands." 1>&2
    exit 1
fi

BASE_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

sudo -v

. ${BASE_PATH}/SETTING
import_dir ${BASE_PATH}/scripts

install_config ~/.gitconfig ${BASE_PATH}/config/git/gitconfig

backup /etc/apt/sources.list
replace_string /etc/apt/sources.list "archive.ubuntu.com" "mirror.kakao.com"
replace_string /etc/apt/sources.list "security.ubuntu.com" "mirror.kakao.com"

run sudo apt update
run sudo apt upgrade

install_packages
# install_fonts
# set_git