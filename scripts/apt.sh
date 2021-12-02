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