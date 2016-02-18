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
    dotenvon $@
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

complete -F ___dotenvlist_autocomplete envon
complete -F ___dotenvlist_autocomplete on
