
source $DOT_FILES_HOME/settings.sh

function dotreload
{
    source $BASH_RC_FILE
    echo "reloaded!!!"
}

function ___dotdbinit
{
    SQLITE_BINARY=$(type -p sqlite3)

    if [ -f "$DB_FILE" ]; then
        echo "the database already exists!!!"
    else
        if [ "$SQLITE_BINARY" != "" ]; then
            $SQLITE_BINARY $DB_FILE "CREATE TABLE configtable(id interge auto increment, attr varchar(60) unique not null, value varchar(200) not null)"
        else
            echo "sqlite3 is not installed!!!"
            echo "install with apt-get install sqlite3"
        fi
    fi
}

function ___dotdb
{
    SQLITE_BINARY=$(type -p sqlite3)
    if [ "$SQLITE_BINARY" == "" ]; then
        echo "sqlite3 is not installed!!!"
        echo "install with apt-get install sqlite3"
    else
        if [ ! -f "$DB_FILE" ]; then
            echo "the database not exists"
            echo "create database!!!"
            ___dotdbinit
        fi
        $SQLITE_BINARY $DB_FILE "$1"
    fi
}

function ___dotvalue
{
    if [ $# -eq 1 ]; then
        value=$(___dotdb 'SELECT "value" FROM configtable')
        return value
    else
        if [ $# -eq 2 ]; then
            echo "set $1 = $2"
        fi
    fi
}
