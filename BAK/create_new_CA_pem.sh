#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh


if [ ! -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A key file does not exist. "; unset TEMP_COLOR; print_color "Run the script create_CA_key.sh first.\nNothing done.\n"
  exit 0
fi

if [ -f myCA.pem ]; then
  TEMP_COLOR=lred; print_color "A pem file with name myCA.pem already exists. "; unset TEMP_COLOR; print_color "Delete the file manually to continue.\nNothing done.\n"
exit 0
fi

if [ "$(cat CA_configuration.cfg | tr -d "[:space:]" | md5sum |  cut -d' ' -f1)" == "2478dabce271059d5f8cb818166fd524" ]; then
  TEMP_COLOR=lred; print_color "CA_configuration.cfg has not been edited.\nIt is not necessary to edit the file, but you may want to.\nPress "; 
  TEMP_COLOR=lcyan; print_color "c"; 
  TEMP_COLOR=lred; print_color " to continue anyway or any other key to exit.\n"; unset TEMP_COLOR;
  read -s -n 1 RESPONSE
  if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi

fi

TEMP_COLOR=lcyan; print_color "You must enter the passphrase for your key.\n"

openssl req -x509 -new -nodes -key myCA.key -sha256 -days ${HOW_MANY_DAYS_VALID} -out myCA.pem -config CA_configuration.cfg  || ERR=TRUE

if [ $ERR ]; then 
  TEMP_COLOR=lred; print_color "Something went wrong. Try again.\n"; unset TEMP_COLOR; 
  exit 0; 
else
  TEMP_COLOR=lcyan; print_color "OK!\n"; unset TEMP_COLOR; 
fi



