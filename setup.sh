# if [ $USER != "root" ]; then
#     echo -e "\033[5;41;1;1;37mERROR, run with sudo or on root\033[0m";
#     exit 0;
# fi


ERROR="\033[5;41;1;1;37m"
END="\033[0m"

source /etc/lsb-release
source /etc/os-release

echo -e "Your OS : \033[32m$DISTRIB_DESCRIPTION\033[0m"

if [[ ${DISTRIB_CODENAME} = "bionic" || ${DISTRIB_CODENAME} = "focal" ]]; then
    :
else
    echo -e "${ERROR}FAIL, CHECK your OS Version. 1804, 2004 is supported only${END}"
    exit 0
fi

sudo dpkg --add-architecture i386

sudo apt install git

git clone https://github.com/mg0721/ubuntu-post-install.git -b temp

bash ubuntu-post-install/install.sh
