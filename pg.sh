
function pgclone {
    if [ $# -eq 2 ]; then
        from_db=$(echo $1 | cut -d '/' -f 2)
        from_user=$(echo $1 | cut -d '@' -f 1)
        from_host=$(echo $1 | cut -d '@' -f 2 | cut -d '/' -f 1)

        to_db=$(echo $2 | cut -d '/' -f 2)
        to_user=$(echo $2 | cut -d '@' -f 1)
        to_host=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1)

        dropdb --if-exists -h $to_host -U $to_user $to_db 2>&1 1>/dev/null
        createdb -h $to_host -U $to_user $to_db
        pg_dump -h $from_host -U $from_user $from_db -O -x | psql -h $to_host -U $to_user $to_db
    else
        echo ""
        echo "Modo de uso: "
        echo ""
        echo "  pgclone [source] [dest]"
        echo "  pgclone user@host/dbsource user@host/dbdest"
        echo ""
    fi
}


function pgload {
    if [ $# -eq 2 ]; then
        to_db=$(echo $2 | cut -d '/' -f 2)
        to_user=$(echo $2 | cut -d '@' -f 1)
        to_host=$(echo $2 | cut -d '@' -f 2 | cut -d '/' -f 1)

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

        dropdb --if-exists -h $to_host -U $to_user $to_db
        createdb -h $to_host -U $to_user $to_db
        if [ "$url_type" == "remote" ]; then
            wget $URL -O- | $compress | psql -U $to_user -h $to_host $to_db
        else
            $compress $URL | psql -U $to_user -h $to_host $to_db
        fi
    else
        echo ""
        echo "Modo de uso: "
        echo ""
        echo "  pgload [source] [dest]"
        echo "  pgload http://localhost/dumps/db.gz user@host/dbdest"
        echo ""
    fi
}
