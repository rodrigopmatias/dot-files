
function dkClear() {
    docker rmi -f $(docker images | grep -i '^<none>' | awk {'print $3'})
    docker rm -f $(docker ps -a | awk {'print $1'})
    docker volume rm $(docker volume ls | awk {'print $2'})
}

function dksContainer() {
    echo $(docker ps -f "name=$1" --format "{{.ID}}") | cut -d ' ' -f 1
}

function  dksExec() {
  name=$1
  shift 1
  docker exec -it $(dksContainer $name) $@
}

function dksTailf() {
  docker service logs -f --since 0s $1
}
