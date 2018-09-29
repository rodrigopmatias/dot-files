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

function _hgupdater_do {
    name=$1

    echo -en " \033[1m\033[32m•\033[0m Update repository \033[1m$name\033[0m ... "
    if [ "${HG_SSH}" != "" ]; then
        hg pull -e "${HG_SSH}" 1> /dev/null 2> /dev/null
        pull=$?
    else
        hg pull -e "${HG_SSH}" 1> /dev/null 2> /dev/null
        pull=$?
    fi

    hg update 1> /dev/null 2> /dev/null
    update=$?

    if [ ! $pull -eq 0 ]; then
        echo -e "\033[1m\033[31mpull failed\033[0m"
    else
        if [ ! $update -eq 0 ]; then
            echo -e "\033[1m\033[31mupdate failed\033[0m"
        else
            echo -e "\033[1m\033[32mdone\033[0m"
        fi
    fi
}

function hgupdater {
    if [ -d "./.hg" ]; then
        _hgupdater_do "current"
    fi

    for name in $(ls); do
        if [ -d "$name/.hg" ]; then
            cd $name
            if [ $? -eq 0 ]; then
                _hgupdater_do $name
                cd ..
            fi
        fi
    done
}

function _hgbranch_do {
    name=$1

    echo -en " \033[1m\033[32m•\033[0m Branch of repository \033[1m$name\033[0m ... "
    branch=$(hg branch)

    echo $branch
}

function hgbranch {
    if [ -d "./.hg" ]; then
        _hgbranch_do "current"
    fi

    for name in $(ls); do
        if [ -d "$name/.hg" ]; then
            cd $name
            if [ $? -eq 0 ]; then
                _hgbranch_do $name
                cd ..
            fi
        fi
    done
}

function _hgmodified_do {
    name=$1

    echo -en " \033[1m\033[32m•\033[0m Check changes in repository \033[1m$name\033[0m ... "
    rst=$(hg st)

    if [ "$rst" == "" ]; then
        echo -e "\033[1m\033[32m(ok)\033[0m"
    else
        echo -e "\033[1m\033[33mchanges found\033[0m"
    fi
}

function hgmodified {
    if [ -d "./.hg" ]; then
        _hgmodified_do "current"
    fi

    for name in $(ls); do
        if [ -d "$name/.hg" ]; then
            cd $name
            if [ $? -eq 0 ]; then
                _hgmodified_do $name
                cd ..
            fi
        fi
    done
}

function _hgpush_do {
    name=$1

    echo -en " \033[1m\033[32m•\033[0m Sending to repository \033[1m$name\033[0m ... "
    if [ "${HG_SSH}" != "" ]; then
        hg push -e "${HG_SSH}" 1> /dev/null 2> /dev/null
        push=$?
    else
        hg push 1> /dev/null 2> /dev/null
        push=$?
    fi

    if [ $push -eq 0 ]; then
        echo -e "\033[1m\033[32mdone\033[0m"
    elif [ $push -eq 1 ]; then
        echo -e "\033[1m\033[32mwithout local changes\033[0m"
    elif [ $push -eq 1 ]; then
        echo -e "\033[1m\033[31mnot is repository\033[0m"
    else
        echo -e "\033[1m\033[31mfailed\033[0m"
    fi
}

function hgpush {
    if [ -d "./.hg" ]; then
        _hgpush_do "current"
    fi

    for name in $(ls); do
        if [ -d "$name/.hg" ]; then
            cd $name
            if [ $? -eq 0 ]; then
                _hgpush_do $name
                cd ..
            fi
        fi
    done
}
