
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
    echo "reloaded!!!"
}

function ___dotdbinit
{
    SQLITE_BINARY=$(type -p sqlite3)

    if [ -f "$DB_FILE" ]; then
        echoer "the database already exists!!!"
    else
        if [ "$SQLITE_BINARY" != "" ]; then
            $SQLITE_BINARY $DB_FILE "CREATE TABLE configtable(id interge auto increment, attr varchar(60) unique not null, value varchar(200) not null)"
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
        if [ ! -f "$DB_FILE" ]; then
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
