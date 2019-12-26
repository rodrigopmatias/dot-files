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

source $DOT_FILES_HOME/core.sh

function ___dotenvcheck
{
    if [ -f "$1/bin/activate" ]; then
        echo 1
    else
        echo 0
    fi
}

function on
{
    envon $@
}

function envon
{
    if [ $# -eq 1 ]; then
        path=$(___dotdb "SELECT value FROM configtable WHERE attr='$1'")
        is_env=$(___dotenvcheck $path)
        if [ $is_env -eq 1 ]; then
            cd $path
            source bin/activate
        else
            echo -e "\033[1m\033[31m ·\033[0m \033[1m$1\033[0m não é um ambiente virtual"
        fi
    else
        echo "modo de uso:"
        echo
        echo "    $0 [varname]"
    fi
}

function envlist
{
    for row in $(___dotdb "SELECT attr, value FROM configtable")
    do
        attr=$(echo $row | cut -d '|' -f 1)
        value=$(echo $row | cut -d '|' -f 2)

        is_env=$(___dotenvcheck $value)
        if [ $is_env -eq 1 ]; then
            echo -e "\033[1m\033[32m · \033[0m \033[1m$attr\033[0m in \033[1m$value\033[0m"
        fi
    done
}

function ___dotenvlist
{
    for row in $(___dotdb "SELECT attr, value FROM configtable")
    do
        attr=$(echo $row | cut -d '|' -f 1)
        value=$(echo $row | cut -d '|' -f 2)

        is_env=$(___dotenvcheck $value)
        if [ $is_env -eq 1 ]; then
            echo $attr
        fi
    done
}

function __dotenvlist_autocomplete_list
{
    list=""

    for row in $(___dotdb "SELECT attr, value FROM configtable")
    do
        attr=$(echo $row | cut -d '|' -f 1)
        value=$(echo $row | cut -d '|' -f 2)

        is_env=$(___dotenvcheck $value)
        if [ $is_env -eq 1 ]; then
            list=$(echo "$list $attr")
        fi
    done

    echo $list
}

function ___dotenvlist_autocomplete
{
    local current=${COMP_WORDS[COMP_CWORD]}
    list=$(__dotenvlist_autocomplete_list)
    COMPREPLY=( $(compgen -W "$list" $current ) )
}

type complete 2>&1 1>/dev/null

if [ $? -eq 0 ]; then
    complete -F ___dotenvlist_autocomplete envon
    complete -F ___dotenvlist_autocomplete on
fi
