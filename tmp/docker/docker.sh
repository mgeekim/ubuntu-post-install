
# export DOCKER_BASE
# export VERSION_COMPOSE
# export SERVICE
# export IMAGE
# export CONTAINER
# export YML
# export USERID
# export GROUPID
# export PWD

export PWD=$(pwd)

echo "@@@@@@@ $PWD"
export DOCKER_BASE=$PWD/docker

export VERSION_COMPOSE=3.8
export SERVICE="ubuntu"
export IMAGE=ubuntu:18.04
export CONTAINER=test-ubuntu
export YML=$DOCKER_BASE/docker-compose.yml

export USERID=$(id -u)
export GROUPID=$(id -g)

rm $YML

cat << EOF > $YML
version: \${VERSION_COMPOSE}
services:
    \${SERVICE}:
        image: \$IMAGE
        container_name: \$CONTAINER
        command: "tail -f /dev/null"
        user: "\$USERID:\$GROUPID"
        working_dir: \$PWD:\$PWD
        env_file:
            - $DOCKER_BASE/.env
        volumes:
            - \$PWD:\$PWD
            - /etc/passwd:/etc/passwd
            - /etc/shadow:/etc/shadow
            - /etc/group:/etc/group
            - /etc/gshadow:/etc/gshadow
EOF

docker-compose -f $YML up -d
docker-compose -f $YML exec $SERVICE /bin/bash

# WiredTiger 오류 <- 계속해서 재시작 되는 문제 있었음
# https://stackoverflow.com/questions/37471929/docker-container-keeps-on-restarting-again-on-again
# https://seorenn.tistory.com/232

# connection refused 에러
# https://stackoverflow.com/questions/24899849/connection-refused-to-mongodb-errno-111