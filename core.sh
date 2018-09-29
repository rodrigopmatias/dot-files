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

alias echoer=">&2 echo"

function dotunset
{
    if [ $# -eq 1 ]; then
        echo "unset $1"
        $(___dotdb "DELETE FROM configtable WHERE attr='${1}'")
    else
        echo 'modo de uso:'
        echo
        echo "   $0 [varname]"
    fi
}

function dotreload
{
    source $BASH_RC_FILE
    ___dotaliasload
    echo "reloaded!!!"
}

function dotalias() {
    if [ "$#" -eq "2" ]; then
        $(___dotdb "INSERT INTO aliastable(attr, value) VALUES('$1', '$2')")
    else
        echo "Modo de uso:"
        echo
        echo "  $0 [aliasname] [aliasvalue]"
    fi
}

function dotaliasdel() {
    if [ "$#" -eq "1" ]; then
        $(___dotdb "DELETE FROM aliastable WHERE attr='$1'")
    else
        echo "Modo de uso:"
        echo
        echo "  $0 [aliasname]"
    fi
}

function ___dotaliasload() {
    tmpfile=$(tempfile)
    echo $(___dotdb "SELECT * FROM aliastable") > $tmpfile

    while read row
    do
        attr=$(echo $row | cut -d '|' -f 2)
        value=$(echo $row | cut -d '|' -f 3)

        alias $attr="$value"
    done <$tmpfile

    rm $tmpfile
}

function ___dotdbinit
{
    SQLITE_BINARY=$(type -p sqlite3)

    if [ -f "$DB_FILE" -a "$DOT_DB_IGNORE" == "" ]; then
        echoer "the database already exists!!!"
    else
        if [ "$SQLITE_BINARY" != "" ]; then
            echoer "prepare tables..."
            $SQLITE_BINARY $DB_FILE "CREATE TABLE IF NOT EXISTS configtable(id interge auto increment, attr varchar(60) unique not null, value varchar(200) not null)"
            $SQLITE_BINARY $DB_FILE "CREATE TABLE IF NOT EXISTS aliastable(id interge auto increment, attr varchar(60) unique not null, value varchar(200) not null)"
        else
            echoer "sqlite3 is not installed!!!"
            echoer "install with apt-get install sqlite3"
        fi
    fi
}

function ___dotdb
{
    SQLITE_BINARY=$(type -p sqlite3)
    if [ "$SQLITE_BINARY" == "" ]; then
        echoer "sqlite3 is not installed!!!"
        echoer "install with apt-get install sqlite3"
    else
        if [ ! -f "$DB_FILE" -o "$DOT_DB_IGNORE" == "1" ]; then
            echoer "the database not exists"
            echoer "create database!!!"
            ___dotdbinit
        fi
        $SQLITE_BINARY $DB_FILE "$1"
    fi
}

function dotvalue
{
    if [ $# -eq 0 ]; then
        for row in $(___dotdb "SELECT * FROM configtable")
        do
            attr=$(echo $row | cut -d '|' -f 2)
            value=$(echo $row | cut -d '|' -f 3)

            echo -e "\033[1m\033[32m · \033[0m\033[1m${attr}\033[0m = ${value}"
        done
    else
        if [ $# -eq 1 ]; then
            value=$(___dotdb "SELECT "value" FROM configtable WHERE attr='${1}'")
            echo $value
        else
            if [ $# -eq 2 ]; then
                echo "set $1 = $2"
                value=$(___dotdb "SELECT "value" FROM configtable WHERE attr='${1}'")
                if [ "$value" == "" ]; then
                    $(___dotdb "INSERT INTO configtable (attr, value) VALUES('${1}', '${2}')")
                else
                    $(___dotdb "UPDATE configtable SET value='${1}' WHERE attr='${2}'")
                fi
            fi
        fi
    fi
}

function dotcd
{
    if [ $# -eq 1 ]; then
        path=$(___dotdb "SELECT value FROM configtable WHERE attr='$1'")
        if [ -d "$path" ]; then
            cd $path
        else
            echo -e "O valor de \033[1m$1\033[0m não é um diretório."
        fi
    else
        echo 'modo de uso:'
        echo
        echo '  $0 [varname]'
    fi
}

function __dotcd_autocomplete_list
{
    list=""

    for row in $(___dotdb "SELECT attr, value FROM configtable")
    do
        attr=$(echo $row | cut -d '|' -f 1)
        value=$(echo $row | cut -d '|' -f 2)

        if [ -d "$value" ]; then
            list=$(echo "$list $attr")
        fi
    done

    echo $list
}

function ___dotcd_autocomplete
{
    local current=${COMP_WORDS[COMP_CWORD]}
    list=$(__dotcd_autocomplete_list)
    COMPREPLY=( $(compgen -W "$list" $current ) )
}

complete -F ___dotcd_autocomplete dotcd

function dotstream
{
    tail -f --bytes=0 $@
}
