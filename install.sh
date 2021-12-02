function import_scripts {
    local path=$1
    for SCRIPT in $path/*;
    do
        . $SCRIPT
    done
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

. SETTING
import_scripts ./scripts/

backup /etc/apt/sources.list
replace_string /etc/apt/sources.list "archive.ubuntu.com" "mirror.kakao.com"
replace_string /etc/apt/sources.list "security.ubuntu.com" "mirror.kakao.com"
run sudo apt update
run sudo apt upgrade

install_packages
install_fonts
set_git