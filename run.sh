#!/bin/bash

. config.rc

if [ $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $NF}' | wc -l) -gt 0 ]
then
  docker kill ${CONTAINER_NAME} 2> /dev/null
  docker rm   ${CONTAINER_NAME} 2> /dev/null
fi

ICINGA2_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${USER}-icinga2)

[ -z ${ICINGA2_IP} ] && { echo "No Icinga2 Container '${USER}-icinga2' running!"; exit 1; }

DOCKER_DASHING_AUTH_TOKEN=${DOCKER_DASHING_AUTH_TOKEN:-aqLiR3RQ84HnasDMbcuTUQKQj87KydL8ucf7pspJ}
DOCKER_DASHING_API_USER=${DOCKER_DASHING_API_USER:-dashing}
DOCKER_DASHING_API_PASS=${DOCKER_DASHING_API_PASS:-icinga2ondashingr0xx}

# ---------------------------------------------------------------------------------------

docker run \
  --interactive \
  --tty \
  --detach \
  --publish=3030:3030 \
  --link ${USER}-icinga2:icinga2 \
  --env AUTH_TOKEN=${DOCKER_DASHING_AUTH_TOKEN} \
  --env ICINGA2_HOST=${ICINGA2_IP} \
  --env ICINGA2_PORT=5665 \
  --env ICINGA2_DASHING_APIUSER=${DOCKER_DASHING_API_USER} \
  --env ICINGA2_DASHING_APIPASS=${DOCKER_DASHING_API_PASS} \
  --hostname=${USER}-${TYPE} \
  --name ${CONTAINER_NAME} \
  ${TAG_NAME}

# ---------------------------------------------------------------------------------------
# EOF
