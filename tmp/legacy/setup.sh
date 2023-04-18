# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

FORE_GREEN='\033[0;32m'
FORE_YELLOW='\033[1;33m'
BACK_RED='\033[41m'
BACK_GREEN='\033[42m'
# FORE_BLACK='\033[30m'
NC='\033[0m'

GIT_MAIL="64mingn@gmail.com"
GIT_ID="mgkim"

ASSET_PATH=./asset
SRC_PATH=./src

# function header() {
#     # Format header text
#     length=${#1}
#     padding=$(( (72 - length) / 2))
#     sep=$(printf '=%.0s' $(seq 1 $padding))
#     echo ""
#     echo -e "${FORE_GREEN}$sep $1 $sep${NC}"
# }

# function ask() {
#     # Ask for input. First parameter: Display text, 2nd parameter variable name
#     default="${!2}"
#     read -rp $'\e[36m'"$1 [default: '$default']: "$'\e[97m' inp
#     inp="${inp:-${default}}"
#     if [ "$inp" == "\n" ] ; then inp=${!2} ; fi
#     printf -v $2 "$inp"
# }

# function ask_yesno() {
#     # Ask yes or no. First Param: Question, 2nd param: Default
#     # Returns True for yes, False for No
#     case $2 in
#         [Yy]* ) opts="[YES/no]" ;;
#         [Nn]* ) opts="[yes/NO]" ;;
#     esac
#     while true; do
#         read -rp $'\e[36m'"$1 $opts: "$'\e[97m' yn
#         yn="${yn:-${2}}"
#         case $yn in
#             [Yy]* ) retval=true ; break ;;
#             [Nn]* ) retval=false ; break ;;
#             * ) echo "Please answer yes or no." ;;
#         esac
#     done
#     echo $retval
# }

# function check_for_sudo() {
#     # Ensure user isn't running as sudo/root. We don't want to screw up any system install
#     if [ "$EUID" == 0 ] ; then
#         error "This install script should not be run with root privileges. Please run as a normal user."
#         exit 1
#     fi
# }

# function mycmd() {
#     $@
#     if [ $? -eq 0 ]; then
#         echo -e "${FORE_YELLOW}Command: $@, OK${NC}"
#     else
#         echo -e "${FORE_YELLOW}Command: $@${NC}, ${BACK_RED}${FORE_BLACK}FAIL${NC}"
#         exit
#     fi
# }

# function myapt() {
#     sudo apt -y $@
#     if [ $? -eq 0 ]; then
#         echo -e "${FORE_YELLOW}Command: sudo apt -y $@, OK${NC}"
#     else
#         echo -e "${FORE_YELLOW}Command: sudo apt -y $@${NC}, ${BACK_RED}${FORE_BLACK}FAIL${NC}"
# #         exit
# #     fi
# }

# function install_fonts() {
#     header "FONTS INSTALL"
#     mycmd git clone git@github.com:powerline/fonts.git
#     mycmd_sudo cp ./fonts/UbuntuMono/*.ttf /usr/local/share/fonts/
# }

function install_python() {
    header "PYTHON"
    mycmd sudo apt -y install python3.7
    mycmd sudo apt -y install python3-pip
    mycmd sudo apt -y install python3-venv
    mycmd sudo apt -y install python3.7-venv
    # MK :
    # After October 2020 you may experience errors when installing or updating packages.
    # This is because pip will change the way that it resolves dependency conflicts.
    # We recommend you use --use-feature=2020-resolver to test your packages with
    # the new resolver before it becomes the default.
    # MK : To solve "AttributeError: module 'enum' has no attribute 'IntFlag'"
    # mycmd python3.7 -m pip install enum34==1.1.8
    # mycmd python3.7 -m pip install --upgrade pip
    # mycmd python3.7 -m pip install pip==20.3.2
    # mycmd python3.7 -m pip install -r ${ASSET_PATH}/python/requirements.txt \
                                        # --use-feature=2020-resolver
}

function install_adb() {
    header "ADB"
    mycmd wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
}

function remove_cuda() {
    sudo apt-get -y --purge remove "*cublas*" "*cufft*" "*curand*" \
                "*cusolver*" "*cusparse*" "*npp*" "*nvjpeg*" "cuda*" "nsight*"
    sudo apt-get -y --purge remove "*nvidia*"
    sudo apt-get -y autoremove
    sudo apt-get autoclean

    # sudo apt-get remove --purge '^nvidia-.*'
    # sudo apt-get remove --purge 'cuda*'
    # sudo apt-get autoremove --purge 'cuda*'
    # sudo rm -rf /usr/local/cuda

    # sudo apt-get purge nvidia*
    # sudo apt-get autoremove
    # sudo apt-get autoclean
    # sudo rm -rf /usr/local/cuda*
}

function install_cuda() {
    header "CUDA"

    sudo apt install nvidia-driver-455


    # MK : Download Installer for Linux WSL-Ubuntu 2.0 x86_64
    # wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
    # sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
    # sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/7fa2af80.pub
    # sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /"
    # sudo apt-get update
    # sudo apt-get -y install cuda

    # MK : CUDA Toolkit 11.1 Update 1 Downloads
    #      Download Installer for Linux WSL-Ubuntu 2.0 x86_64
    wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
    sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
    # wget https://developer.download.nvidia.com/compute/cuda/11.1.1/local_installers/cuda-repo-wsl-ubuntu-11-1-local_11.1.1-1_amd64.deb
    sudo dpkg -i cuda-repo-wsl-ubuntu-11-1-local_11.1.1-1_amd64.deb
    sudo apt-key add /var/cuda-repo-wsl-ubuntu-11-1-local/7fa2af80.pub
    sudo apt-get update
    sudo apt-get -y install cuda
    # sudo apt-get -y install cuda=11.1.1-1 --allow-downgrades
    # sudo apt-get autoremove

    # MK : Download Installer for Linux Ubuntu 18.04 x86_64
    # wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
    # sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
    # sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    # sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"
    # sudo apt-get update
    # sudo apt-get -y install cuda
}


function ready() {
    header "READY AND ETC"
    CHANGE_REPO=$(ask_yesno "Do you want to change Ubuntu repo?" "YES")
    myapt update
    if ${CHANGE_REPO}; then
        myapt install python3.7
        mycmd sudo python3.7 ${SRC_PATH}/python/setup.py --chg_sources
        mycmd sudo python3.7 ${SRC_PATH}/python/setup.py --cp_vscode
        mycmd sudo python3.7 ${SRC_PATH}/python/setup.py --add_alias
        source ~/.bashrc
    fi
    myapt update
    myapt upgrade
}

# function install_utils() {
#     header "UTILS"
#     myapt install dos2unix
#     myapt install unrar zip unzip
#     myapt install terminator dbus-x11 # For terminator GUI
#     mycmd sudo systemd-machine-id-setup
# }

function install_kotlin() {
    header "KOTLIN"
    myapt install openjdk-8-jre
    curl -s https://get.sdkman.io | bash &> /dev/null
    mycmd source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install kotlin
}

function install_docker() {
    header "NVIDIA DOCKER"
    curl https://get.docker.com | sh
    # sudo apt -y install docker.io
    # sudo adduser $USER docker
    sudo usermod -aG docker $USER

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    curl -s -L https://nvidia.github.io/libnvidia-container/experimental/$distribution/libnvidia-container-experimental.list | sudo tee /etc/apt/sources.list.d/libnvidia-container-experimental.list
    sudo apt-get update
    sudo apt-get install -y nvidia-docker2
    sudo service docker stop
    sudo service docker start
}

ready
# install_network
# install_utils

# install_python
# install_git

# remove_cuda
# install_cuda
# install_docker

# install_kotlin

# install_fonts
# install_zsh
