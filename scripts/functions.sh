function is_symbolic {
    TARGET=$1

    if [ -L "${TARGET}" ]; then
        return 0
    fi
    return 1
}

function is_file {
    TARGET=$1

    if [ -f "${TARGET}" ]; then
        return 0
    fi
    return 1
}

function get_list_from_file {
    FNAME=$1

    while read -r line; do
        if [[ ${line} != "#"* ]]; then
            echo ${line}
        fi
    done <${FNAME}
}

function get_basepath {
    BASE_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

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
        echo ${NEW_STRING} >>${FILE}
    fi
}

function already_backedup {
    TARGET=$1

    parent="$(dirname "${TARGET}")"
    file="$(basename "${TARGET}")"
    re="${parent}/${file}.bak_[0-9]+_[0-9]+"

    if [ $(find ${parent} -maxdepth 1 -regex "${re}" | wc -l) -gt 0 ]; then
        return 0
    fi
    return 1
}

function create_symlink {
    ORIGINAL=$1
    COPY=$2

    ln -s ${ORIGINAL} ${COPY}
}

function backup {
    TARGET=$1
    if already_backedup ${TARGET}; then
        echo "Already backed-up : ${TARGET}"
    else
        sudo mv "${TARGET}" "${TARGET}.bak_$(date '+%Y%m%d_%H%M%S')"
    fi
}

function replace_string {
    local fpath=$1
    local old=$2
    local new=$3

    sudo sed -i "s/$old/$new/g" $fpath
}

function header {
    length=${#1}
    padding=$(((72 - length) / 2))
    sep=$(printf '=%.0s' $(seq 1 $padding))
    echo ""
    echo -e "${FORE_GREEN}$sep $1 $sep${NC}"
}

function ask_yesno {
    # Ask yes or no. First Param: Question, 2nd param: Default
    # Returns True for yes, False for No
    case $2 in
    [Yy]*) opts="[YES/no]" ;;
    [Nn]*) opts="[yes/NO]" ;;
    esac
    while true; do
        read -rp $'\e[36m'"$1 $opts: "$'\e[97m' yn
        yn="${yn:-${2}}"
        case $yn in
        [Yy]*)
            retval=true
            break
            ;;
        [Nn]*)
            retval=false
            break
            ;;
        *) echo "Please answer yes or no." ;;
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
        exit 0
    fi
}

function install_config {
    SOURCE_PATH=$1
    TARGET_PATH=$2
    mkdir -p "$(dirname ${TARGET_PATH})"

    if ! is_file ${SOURCE_PATH}; then
        echo "Source path ${SOURCE_PATH} does not exist."
        return
    fi

    if is_symbolic ${TARGET_PATH}; then
        echo "Remove symbolic and re-create link : ${TARGET_PATH}"
        rm ${TARGET_PATH}
        create_symlink ${SOURCE_PATH} ${TARGET_PATH}
    elif is_file ${TARGET_PATH}; then
        echo "Backup file and create symlink : ${TARGET_PATH}"
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
