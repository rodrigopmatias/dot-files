#
#
#
source settings.sh

REPO="git@github.com:rodrigopmatias/dot-files.git"

function __path_git
{
    GIT_PATH=$(type -p git)

    return $GIT_PATH
}

function dotupdate
{
    if [ ! -d $DOT_FILES_HOME ]; then
        echo "dotfiles not installed!!!"
        echo "run dotinstall"
    else
        echo "dot files installed!!!"
        gitbin=__path_git

        if [ "$gitbin" != "" ]; then
            echo "ok, update"
            cwd=$(pwd)
            cd $DOT_FILES_HOME
            git pull
            cd $cwd
        else
            echo "git not installed, install with sudo apt-get install git-core"
        fi
    fi
}

function dotinstall
{
    if [ ! -d $DOT_FILES_HOME ]; then
        echo "dotfiles not installed!!!"
        gitbin=__path_git

        if [ "$gitbin" != "" ]; then
            echo "ok, install"
            git clone $REPO $DOT_FILES_HOME
        else
            echo "git not installed, install with sudo apt-get install git-core"
        fi
    else
        echo "dot files installed!!!"
    fi
}
