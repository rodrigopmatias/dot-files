
function docker_clear() {
    docker rmi -f $(docker images | grep -i '^<none>' | awk {'print $3'})
    docker rm -f $(docker ps -a | awk {'print $1'})
    docker volume rm $(docker volume ls | awk {'print $2'})
}
