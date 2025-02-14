#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR

source ${SCRIPT_DIR}/vars.sh
source ${SCRIPT_DIR}/functions.sh

# remove spaces if exist from MY_ORGANIZATION
MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')

echo "test" > ${MY_ORGANIZATION}.txt
if [ -f ${MY_ORGANIZATION}.txt ]; then
  rm -f ${MY_ORGANIZATION}.txt
  TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR; 
else 
  TEMP_COLOR=lred; print_color "Something went wrong with test file creation.\n"; unset TEMP_COLOR; exit 1
fi



# if the file exists but it is empty, remove it
if [ ! -s ${MY_ORGANIZATION}.key ] && [ -f ${MY_ORGANIZATION}.key ]; then rm -f ${MY_ORGANIZATION}.key; fi
if [ -f ${MY_ORGANIZATION}.key ]; then
  TEMP_COLOR=lred; print_color "A key file with name ${MY_ORGANIZATION}.key already exists.\n"; unset TEMP_COLOR; 
  print_color "Delete the file manually to create a new one with this script.\nNothing done.\n"
exit 0
fi

openssl genrsa -out ${MY_ORGANIZATION}.key 2048 || ERR=TRUE

if [ $ERR ]; then 
  TEMP_COLOR=lred; print_color "Something went wrong. Try again.\n"; unset TEMP_COLOR; 
  exit 0; 
else
  TEMP_COLOR=lcyan; print_color "OK\n"; unset TEMP_COLOR; 
  if [ -f ${MY_ORGANIZATION}.key ]; then 
    chmod 644 ${MY_ORGANIZATION}.key
    TEMP_COLOR=lcyan; print_color "File ${MY_ORGANIZATION}.key created successfully.\n"; unset TEMP_COLOR;
  fi
fi


