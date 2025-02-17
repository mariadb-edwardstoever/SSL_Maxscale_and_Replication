#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh 2>/dev/null

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi

if [ ! -f myCA.pem ]; then 
  echo "myCA.pem does not exist. Exiting."; exit 0
fi

TEMP_COLOR=lcyan; print_color "Details of myCA.pem:\n"; unset TEMP_COLOR;
openssl x509 -text -in myCA.pem
