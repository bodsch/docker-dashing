#!/bin/bash

. config.rc

if [ $(docker ps -a | grep ${CONTAINER_NAME} | awk '{print $NF}' | wc -l) -gt 0 ]
then
  docker kill ${CONTAINER_NAME} 2> /dev/null
  docker rm   ${CONTAINER_NAME} 2> /dev/null
fi

# ---------------------------------------------------------------------------------------

docker run \
  --interactive \
  --tty \
  --detach \
  --publish=3030:3030 \
  --link ${USER}-icinga2:icinga2 \
  --env AUTH_TOKEN="xxxxxx" \
  --env ICINGA2_HOST=${USER}-icinga2.docker \
  --env ICINGA2_PORT=5665 \
  --env ICINGA2_DASHING_APIUSER="dashing" \
  --env ICINGA2_DASHING_APIPASS="icinga2ondashingr0xx" \
  --dns=172.17.0.1 \
  --hostname=${USER}-${TYPE} \
  --name ${CONTAINER_NAME} \
  ${TAG_NAME}

[ -x /usr/local/bin/update-docker-dns.sh ] && sudo /usr/local/bin/update-docker-dns.sh

# ---------------------------------------------------------------------------------------
# EOF
