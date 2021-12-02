function backup {
    old_fpath=$1
    current_time=$(date "+%Y.%m.%d-%H.%M.%S")
    new_fpath=$old_fpath.$current_time
    sudo cp $old_fpath $new_fpath
}

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