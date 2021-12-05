function is_symbolic {
    TARGET=$1
    if [ -L "${TARGET}" ]; then
        return 0; fi
    return 1
}

function is_file {
    TARGET=$1
    if [ -f "${TARGET}" ]; then
        return 0; fi
    return 1
}

function get_list_from_file {
    FNAME=$1

    while read -r line; do
        if [[ ${line} != "#"* ]]; then
            echo ${line}
        fi
    done < ${FNAME}
}

function get_basepath {
    # echo
    BASE_PATH="$(dirname "$0")"
    # echo ${BASE_PATH}
    BASE_PATH="$(cd "${BASE_PATH}" && pwd)/$(basename "$0")"
    # echo ${BASE_PATH}
    if [ -z "${BASE_PATH}" ]; then
        exit 1
    fi
    echo "${BASE_PATH}"
}

function replace_or_add {
    FILE=$1
    TARGET_STRING=$2
    NEW_STRING=$3

    if grep -q ${TARGET_STRING} ${FILE}; then
        sudo sed -i "/^${TARGET_STRING}*/c\\${NEW_STRING}" ${FILE}
    else
        echo ${NEW_STRING} >> ${FILE}
    fi
}

function is_backedup {
    TARGET=$1

    parent="$(dirname "${TARGET}")"
    file="$(basename "${TARGET}")"
    res="${parent}/${file}.bak_[0-9]+_[0-9]+"

    if [ $(find ${parent} -maxdepth 1 -regex "$re" | wc -l) -gt 0 ]; then
        return 0; fi
    return 1
}

function create_symlink {
    ORIGINAL=$1
    COPY=$2

    ln -s ${ORIGINAL} ${COPY}
}

function backup {
    TARGET=$1
    mv "${TARGET}" "${TARGET}.bak_$(date '+%Y%m%d_%H%M%S')"
}

# function backup {
#     old_fpath=$1
#     current_time=$(date "+%Y.%m.%d-%H.%M.%S")
#     new_fpath=$old_fpath.$current_time
#     sudo cp $old_fpath $new_fpath
# }

function replace_string {
    local fpath=$1
    local old=$2
    local new=$3

    sudo sed -i "s/$old/$new/g" $fpath
}

function header {
    # Format header text
    length=${#1}
    padding=$(( (72 - length) / 2))
    sep=$(printf '=%.0s' $(seq 1 $padding))
    echo ""
    echo -e "${FORE_GREEN}$sep $1 $sep${NC}"
}

function ask_yesno {
    # Ask yes or no. First Param: Question, 2nd param: Default
    # Returns True for yes, False for No
    case $2 in
        [Yy]* ) opts="[YES/no]" ;;
        [Nn]* ) opts="[yes/NO]" ;;
    esac
    while true; do
        read -rp $'\e[36m'"$1 $opts: "$'\e[97m' yn
        yn="${yn:-${2}}"
        case $yn in
            [Yy]* ) retval=true ; break ;;
            [Nn]* ) retval=false ; break ;;
            * ) echo "Please answer yes or no." ;;
        esac
    done
    echo $retval
}

function run {
    $@
    result=$?
    echo -ne ${FG_YELLOW} "Command: $@, "${NC}
    if [ $result -eq 0 ]; then
        echo -e ${FG_YELLOW}"OK"${NC}
    else
        echo -e ${BG_RED}${FG_BLACK}"FAIL"${NC}
        exit
    fi
}

function install_config {
    TARGET_PATH=$1
    SOURCE_PATH=$2
    mkdir -p "`dirname \"${TARGET_PATH}\"`"

    if ! is_file ${SOURCE_PATH}; then
        echo "Source path ${SOURCE_PATH} does not exist."
        return; fi

    if is_symbolic ${TARGET_PATH}; then
        echo "Remove symbolic and re-create link"
        rm ${TARGET_PATH}
        create_symlink ${SOURCE_PATH} ${TARGET_PATH}
    elif is_file ${TARGET_PATH}; then
        echo "Backup file and create symlink"
        backup ${TARGET_PATH}
        create_symlink ${SOURCE_PATH} ${TARGET_PATH}
    else
        create_symlink ${SOURCE_PATH} ${TARGET_PATH}
    fi
}

function install_apt {
    LIST=$1
    for PACKAGE in $(cat $LIST); do
        run sudo apt install -y $PACKAGE
    done
}

function install_packages {
    install_apt './asset/packages.list'
}

function install_fonts {
    install_apt './asset/fonts.list'
}

function set_git {
    git config --global user.name ${GIT_NAME}
    git config --global user.email ${GIT_MAIL}
    # Color auto
    git config --global color.ui auto
    # Ignore file permission change
    git config --global core.fileMode false
    # git config --global core.whitespace trailing-space
    #,-space-before-tab,indent-with-non-tab,tab-in-indent,cr-at-eol


    # Set LF as default and CRLF will be changed to LF.
    git config --global core.autocrlf input # true : for windows os
    git config --global core.whitespaces cr-at-eol

    # Only push the current branch, but refuses to push
    # if branch name is different
    # simple -> matching : if want to push all name-matched branches
    git config --global push.default simple

    # git config --global http.proxy http://address
    git config --global http.sslverify false
    # git config --global http.sslCAInfo filepath


    git config --global core.pager "less -F -X"
    git config --list
}