#!/bin/bash

. config.rc

if [ $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $NF}' | wc -l) -gt 0 ]
then
  docker kill ${CONTAINER_NAME} 2> /dev/null
  docker rm   ${CONTAINER_NAME} 2> /dev/null
fi

ICINGA2_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${USER}-icinga2)
GRAPHITE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${USER}-graphite)

DOCKER_DASHING_AUTH_TOKEN=${DOCKER_DASHING_AUTH_TOKEN:-aqLiR3RQ84HnasDMbcuTUQKQj87KydL8ucf7pspJ}

# [ -z ${ICINGA2_IP} ] && { echo "No Icinga2 Container '${USER}-icinga2' running!"; exit 1; }

docker_opts=
docker_opts="${docker_opts} --interactive"
docker_opts="${docker_opts} --tty"
docker_opts="${docker_opts} --detach"
docker_opts="${docker_opts} --publish=3030:3030"
docker_opts="${docker_opts} --hostname=${USER}-${TYPE}"
docker_opts="${docker_opts} --name=${CONTAINER_NAME}"
docker_opts="${docker_opts} --env AUTH_TOKEN=${DOCKER_DASHING_AUTH_TOKEN}"

if [ ! -z ${ICINGA2_IP} ]
then
  DOCKER_DASHING_API_USER=${DOCKER_DASHING_API_USER:-dashing}
  DOCKER_DASHING_API_PASS=${DOCKER_DASHING_API_PASS:-icinga2ondashingr0xx}

  docker_opts="${docker_opts} --link ${USER}-icinga2:icinga2"
  docker_opts="${docker_opts} --env ICINGA2_HOST=${ICINGA2_IP}"
  docker_opts="${docker_opts} --env ICINGA2_PORT=5665"
  docker_opts="${docker_opts} --env ICINGA2_DASHING_APIUSER=${DOCKER_DASHING_API_USER}"
  docker_opts="${docker_opts} --env ICINGA2_DASHING_APIPASS=${DOCKER_DASHING_API_PASS}"
fi

if [ ! -z ${GRAPHITE_IP} ]
then
  docker_opts="${docker_opts} --env GRAPHITE_HOST=${GRAPHITE_IP}"
  docker_opts="${docker_opts} --env GRAPHITE_PORT=8080"
fi

# ---------------------------------------------------------------------------------------

docker run \
  ${docker_opts} \
  ${TAG_NAME}

# docker run \
#   --interactive \
#   --tty \
#   --detach \
#   --publish=3030:3030 \
#   --link ${USER}-icinga2:icinga2 \
#   --env AUTH_TOKEN=${DOCKER_DASHING_AUTH_TOKEN} \
#   --env ICINGA2_HOST=${ICINGA2_IP} \
#   --env ICINGA2_PORT=5665 \
#   --env ICINGA2_DASHING_APIUSER=${DOCKER_DASHING_API_USER} \
#   --env ICINGA2_DASHING_APIPASS=${DOCKER_DASHING_API_PASS} \
#   --hostname=${USER}-${TYPE} \
#   --name ${CONTAINER_NAME} \
#   ${TAG_NAME}

# ---------------------------------------------------------------------------------------
# EOF
