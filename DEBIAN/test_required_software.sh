#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
source ${SCRIPT_DIR}/functions.sh
unset NEED2INSTALL

get_linux_type;


if [ ! "${LINUX_TYPE}" == "DEBIAN" ]; then
  echo "This does not appear to be Debian GNU/Linux. Exiting."; exit 1
fi

if [ ! $(which openssl 2>/dev/null) ]; then 
  NEED2INSTALL=TRUE
  apt install openssl 
fi

if [ ! $(which update-ca-certificates 2>/dev/null) ]; then
  NEED2INSTALL=TRUE
  apt install ca-certificates
fi

if [ ! ${NEED2INSTALL} ]; then 
  echo "The required software is installed."
fi

