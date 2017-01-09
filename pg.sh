
function pgclone {
    if [ $# -eq 2 ]; then
        from_db=$(echo $1 | cut -d '/' -f 2)
        from_user=$(echo $1 | cut -d '@' -f 1)
        from_host=$(echo $1 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 1)
        from_port=$(echo $1 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 2)

        if [ "$from_port" == "$from_host" ]; then
            from_port=5432
        fi

        to_db=$(echo $2 | cut -d '/' -f 2)
        to_user=$(echo $2 | cut -d '@' -f 1)
        to_host=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 1)
        to_port=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 2)

        if [ "$to_port" == "$to_host" ]; then
            to_port=5432
        fi

        if [ "$DEBUG" ]; then
            echo -e "\033[1mSource\033[0m"
            echo -e "\033[1mHost:\033[0m $from_host"
            echo -e "\033[1mPort:\033[0m $from_port"
            echo -e "\033[1mUser:\033[0m $from_user"
            echo -e "\033[1mDatabase:\033[0m $from_db"
            echo ""
            echo -e "\033[1mDestination\033[0m"
            echo -e "\033[1mHost:\033[0m $to_host"
            echo -e "\033[1mPort:\033[0m $to_port"
            echo -e "\033[1mUser:\033[0m $to_user"
            echo -e "\033[1mDatabase:\033[0m $to_db"
        fi

        pgclose $2
        dropdb --if-exists -p $to_port -h $to_host -U $to_user -p $to_port $to_db 2>&1 1>/dev/null
        createdb -p $to_port -h $to_host -U $to_user -p $to_port $to_db
        pg_dump -p $from_port -h $from_host -U $from_user $from_db -O -x | psql  -p $to_port -h $to_host -U $to_user $to_db
    else
        echo ""
        echo "Modo de uso: "
        echo ""
        echo "  pgclone [source] [dest]"
        echo "  pgclone user@host[:port]/dbsource user@host[:port]/dbdest"
        echo ""
    fi
}

function pgclose {
    if [ $# -eq 1 ]; then
        to_db=$(echo $1 | cut -d '/' -f 2)
        to_user=$(echo $1 | cut -d '@' -f 1)
        to_host=$(echo $1 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 1)
        to_port=$(echo $1 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 2)

        if [ "$to_port" == "$to_host" ]; then
            to_port=5432
        fi

        psql -p $to_port -h $to_host -U $to_user $to_db <<EOF
SELECT
    pg_terminate_backend(pid)
FROM
    pg_stat_activity
WHERE
    pid <> pg_backend_pid()
    AND datname = '$to_db'
    ;
EOF
        echo "pronto!!!"
    else
        echo ""
        echo "Modo de uso: "
        echo ""
        echo "  pgclose [database]"
        echo "  pglclose user@host[:port]/dbdest"
        echo ""
    fi
}


function pgload {
    if [ $# -eq 2 ]; then
        to_db=$(echo $2 | cut -d '/' -f 2)
        to_user=$(echo $2 | cut -d '@' -f 1)
        to_host=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 1)
        to_port=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1 | cut -d ':' -f 2)

        if [ "$to_port" == "$to_host" ]; then
            to_port=5432
        fi

        URL=$1
        ext=$(echo ${URL##*.})

        url_type=$(python3 -c "import sys, os; print('file' if os.path.isfile(sys.argv[1]) else 'remote')" $URL)

        compress=""
        case "$ext" in
            "sql")
                compress="cat"
                ;;
            "gz")
                compress="gzip -c -d"
                ;;
            "bz2")
                compress="bzip2 -c -d"
                ;;
            "xz")
                compress="lzma -c -d"
                ;;
            *)
                echo "O formato '$ext' do dump não é suportado."
                return 1
                ;;
        esac

        if [ "$DEBUG" ]; then
            echo -e "\033[1mSource\033[0m"
            echo -e "\033[1mURL:\033[0m $URL"
            echo ""
            echo -e "\033[1mDestination\033[0m"
            echo -e "\033[1mHost:\033[0m $to_host"
            echo -e "\033[1mPort:\033[0m $to_port"
            echo -e "\033[1mUser:\033[0m $to_user"
            echo -e "\033[1mDatabase:\033[0m $to_db"
        fi

        pgclose $2
        dropdb --if-exists -p $to_port -h $to_host -U $to_user $to_db
        createdb -p $to_port -h $to_host -U $to_user $to_db

        if [ "$url_type" == "remote" ]; then
            curl $URL | $compress | psql -U $to_user -p $to_port -h $to_host $to_db
        else
            $compress $URL | psql -p $to_port -U $to_user -h $to_host $to_db
        fi
    else
        echo ""
        echo "Modo de uso: "
        echo ""
        echo "  pgload [source] [dest]"
        echo "  pgload http://localhost/dumps/db.gz user@host[:port]/dbdest"
        echo ""
    fi
}
