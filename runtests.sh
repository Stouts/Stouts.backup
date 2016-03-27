#!/bin/bash

IMAGES=(
    "horneds/stouts-centos7"
    "horneds/stouts-ubuntu14.04"
    "horneds/stouts-debian8"
)

TESTS=(
    "ansible-playbook -c local --syntax-check test.yml"
    "ansible-playbook -c local test.yml"
    "test -x /usr/bin/duply"
)

APPDIR=/var/tests
CURDIR=`pwd`
ARGS=("$@")

docker info || exit 1

assert () {
    echo "ASSERT: $1"
    execute "$@" || ( echo ${2-'Test is failed'} && exit 1 )
    echo "SUCCESS"
}

execute () {
    docker exec -it $RUNNER $1
    return $?
}

suite () {

    echo "================="
    echo "RUN IMAGE: $1"
    echo "================="

    for TEST in "${TESTS[@]}"; do
        assert "$TEST" || ( echo "FAILED" && exit 1 )
    done

    echo
    
}


for IMAGE in "${IMAGES[@]}"
do

    RUNNER=`docker run -v $CURDIR:$APPDIR -w $APPDIR -dit $IMAGE bash`

    suite $IMAGE || {
        echo "Tests are failed $IMAGE"
        docker stop $RUNNER
        exit 1
    }

    if [[ "$1" = "shell" ]]; then
        echo "Run shell"
        execute /bin/bash
    fi

    docker stop $RUNNER

done
