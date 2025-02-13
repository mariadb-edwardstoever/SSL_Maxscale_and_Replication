#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR
source ${SCRIPT_DIR}/functions.sh

if [ -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A key file myCA.key already exists. "; unset TEMP_COLOR; print_color "Delete the file manually to continue.\nNothing done.\n"
  exit 0
fi

if [ -f myCA.pem ]; then
  TEMP_COLOR=lred; print_color "A pem file with name myCA.pem already exists. "; unset TEMP_COLOR; print_color "Delete the file manually to continue.\nNothing done.\n"
exit 0
fi

TEMP_COLOR=lcyan
cp ../AUTHORITY/myCA.key . &&  print_color "File myCA.key copied.\n" || ERR=true
cp ../AUTHORITY/myCA.pem . &&  print_color "File myCA.pem copied.\n" || ERR=true
unset TEMP_COLOR

if [ $ERR ]; then 
  TEMP_COLOR=lred; print_color "Something went wrong.\n"; unset TEMP_COLOR; 
  exit 0; 
else
  TEMP_COLOR=lcyan; print_color "The passphrase for myCA.key is "; TEMP_COLOR=lmagenta; print_color "mariadb"; TEMP_COLOR=lcyan; print_color ". That information saved in file myCA_key_passphrase.txt!\n"; unset TEMP_COLOR; 
  echo "mariadb" > myCA_key_passphrase.txt
fi

