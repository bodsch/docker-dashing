#!/bin/sh

initfile=/opt/run.init

AUTH_TOKEN=${AUTH_TOKEN:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}
ICINGA2_HOST=${ICINGA2_HOST:-"localhost"}
ICINGA2_PORT=${ICINGA2_PORT:-"5665"}
ICINGA2_DASHING_APIUSER=${ICINGA2_DASHING_APIUSER:-"dashing"}
ICINGA2_DASHING_APIPASS=${ICINGA2_DASHING_APIPASS:-"icinga"}

DASHING_PATH="/opt/dashing/icinga2"
CONFIG_FILE="${DASHING_PATH}/config.ru"

# -------------------------------------------------------------------------------------------------

if [ ! -f "${initfile}" ]
then

  if [ -f ${CONFIG_FILE} ]
  then
    sed -i 's,%AUTH_TOKEN%,'${AUTH_TOKEN}',g' ${CONFIG_FILE}
  fi

  if [ -f ${DASHING_PATH}/jobs/icinga2.rb ]
  then
    sed -i \
      -e 's/%ICINGA2_HOST%/'${ICINGA2_HOST}'/g' \
      -e 's/%ICINGA2_PORT%/'${ICINGA2_PORT}'/g' \
      -e 's/%ICINGA2_DASHING_APIUSER%/'${ICINGA2_DASHING_APIUSER}'/g' \
      -e 's/%ICINGA2_DASHING_APIPASS%/'${ICINGA2_DASHING_APIPASS}'/g' \
      ${DASHING_PATH}/jobs/icinga2.rb
  fi

  if [ -f ${DASHING_PATH}/run.sh ]
  then
    sed -i 's|bash|sh|g' ${DASHING_PATH}/run.sh
  fi

  touch ${initfile}

  echo -e "\n"
  echo " ==================================================================="
  echo " Dashing AUTH_TOKEN set to '${AUTH_TOKEN}'"
  echo " ==================================================================="
  echo ""

fi

# -------------------------------------------------------------------------------------------------

echo -e "\n Starting Supervisor.\n\n"

if [ -f /etc/supervisord.conf ]
then
  /usr/bin/supervisord -c /etc/supervisord.conf >> /dev/null
fi


# EOF
