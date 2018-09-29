
function dkclear() {
    docker rmi -f $(docker images | grep -i '^<none>' | awk {'print $3'})
    docker rm -f $(docker ps -a | awk {'print $1'})
    docker volume rm $(docker volume ls | awk {'print $2'})
}

function dkcontainer() {
    echo $(docker ps -f "name=$1" --format "{{.ID}}") | cut -d ' ' -f 1
}

function  dkexec() {
  name=$1
  shift 1
  docker exec -it $(dkcontainer $name) $@
}

function dktailf() {
  docker service logs -f --since 0s $1
}

function dkrestart() {
    while [ $1 ]; do
        docker service update ${1} --force
        shift 1
    done
}
