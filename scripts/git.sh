function set_git {
    git config --global user.name $GIT_NAME
    git config --global user.email $GIT_MAIL
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