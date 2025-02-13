#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh

MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')

openssl x509 -text -in ${MY_ORGANIZATION}.pem
