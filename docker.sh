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
