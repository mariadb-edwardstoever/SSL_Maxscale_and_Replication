#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR
source ${SCRIPT_DIR}/functions.sh 
source ${SCRIPT_DIR}/vars.sh

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi


if [ ! "${RSA}" == "4096" ]; then RSA=2048; fi

# if the file exists but it is empty, remove it
if [ ! -s myCA.key ] && [ -f myCA.key ]; then rm -f myCA.key; fi
if [ -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A key file with name myCA.key already exists. "; unset TEMP_COLOR; print_color "Delete the file manually to continue.\nNothing done.\n"
exit 0
fi


TEMP_COLOR=lcyan; print_color "You must enter a passphrase for your key two times. "
TEMP_COLOR=lred; print_color "Do not lose your passphrase!\n"; unset TEMP_COLOR

openssl genrsa -des3 -out myCA.key ${RSA} || ERR=TRUE

if [ $ERR ]; then 
  TEMP_COLOR=lred; print_color "Something went wrong. Perhaps the passphrases did not match. Try again.\n"; unset TEMP_COLOR; 
  exit 0; 
else
  TEMP_COLOR=lcyan; print_color "OK!\n"; unset TEMP_COLOR; 
fi

# if the file exists but it is empty, remove it
if [ ! -s myCA.key ] && [ -f myCA.key ]; then rm -f myCA.key; fi

