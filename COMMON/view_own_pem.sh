#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi


MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')


if [ -f ${MY_ORGANIZATION}.pem ]; then
  TEMP_COLOR=lcyan; print_color "Details of ${MY_ORGANIZATION}.pem:\n"; unset TEMP_COLOR;
  openssl x509 -text -in ${MY_ORGANIZATION}.pem
  echo; echo;
fi


if [ -f server_${MY_ORGANIZATION}.pem ]; then
  TEMP_COLOR=lcyan; print_color "Details of server_${MY_ORGANIZATION}.pem:\n"; unset TEMP_COLOR;
  openssl x509 -text -in server_${MY_ORGANIZATION}.pem
  echo; echo;
fi

if [ -f client_${MY_ORGANIZATION}.pem ]; then
  TEMP_COLOR=lcyan; print_color "Details of client_${MY_ORGANIZATION}.pem:\n"; unset TEMP_COLOR;
  openssl x509 -text -in client_${MY_ORGANIZATION}.pem
  echo; echo;
fi
