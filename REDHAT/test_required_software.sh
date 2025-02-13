#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

unset NEED2INSTALL
if [ ! "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | grep 'Red Hat Enterprise Linux')" ]; then
  echo "This does not appear to be Red Hat Enterprise Linux. Exiting."; exit 1
fi

if [ ! $(which openssl 2>/dev/null) ]; then 
  NEED2INSTALL=TRUE
  yum install openssl 
fi

if [ ! $(which update-ca-trust 2>/dev/null) ]; then
  NEED2INSTALL=TRUE
  yum install ca-certificates
fi

if [ ! ${NEED2INSTALL} ]; then 
  echo "The required software is available."
fi

