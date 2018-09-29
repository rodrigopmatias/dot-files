# MIT License
#
# Copyright (c) 2017 Rodrigo Pinheiro Matias
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

source $DOT_FILES_HOME/settings.sh

REPO="git@github.com:rodrigopmatias/dot-files.git"

function GIT_BINARY
{
    git_binary=$(type -p git)
    return $git_binary
}

function dotupdate
{
    if [ ! -d $DOT_FILES_HOME ]; then
        echo "dotfiles not installed!!!"
        echo "run dotinstall"
    else
        echo "dot files installed!!!"
        gitbin=GIT_BINARY

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
        gitbin=GIT_BINARY

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
