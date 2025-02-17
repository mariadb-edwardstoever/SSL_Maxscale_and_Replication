#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
unset ERR 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh 2>/dev/null

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi

if [ -f vars.sh ]; then
  if [ ! "$(cat vars.sh | tr -d "[:space:]" | md5sum |  cut -d' ' -f1)" == "096a20b1c9b30dbb24922f2ee93f3b01" ]; then
        TEMP_COLOR=lcyan; print_color  "The file vars.sh has been edited. It will not be overwritten.\n" unset TEMP_COLOR;
        VARS_EDITED=TRUE
  fi
fi


if [ ! $VARS_EDITED ]; then
  TEMP_COLOR=lcyan; print_color "Copying vars.sh. "; 
  TEMP_COLOR=lred; print_color "This file should be edited before you continue.\n"; unset TEMP_COLOR;
  cp ../COMMON/vars.sh .
fi

if [ ! "$(ls -lrth  *.key *.csr *.srl *.pem *.crt myCA_key_passphrase.txt 2>/dev/null)" ]; then
   TEMP_COLOR=lgreen; print_color "Script completed OK.\n\n"; exit 0;
fi

TEMP_COLOR=lred;  print_color "These files will be DELETED if you agree:\n"
ls -lrth  *.key *.csr *.srl *.pem *.crt myCA_key_passphrase.txt 2>/dev/null
TEMP_COLOR=lred;  print_color "This script will remove all previously created certificate files from the directory ${SCRIPT_DIR}.\nPress "; 
TEMP_COLOR=lcyan; print_color "x"; 
TEMP_COLOR=lred;  print_color " to delete all of these files. Any other key will exit.\n";

read -s -n 1 RESPONSE
if [ ! "$RESPONSE" = "x" ]; then printf "Nothing done.\n"; exit 0; fi

rm -f *.key *.csr *.srl *.pem *.crt myCA_key_passphrase.txt || ERR=TRUE

if [ $ERR ]; then
  TEMP_COLOR=lred; print_color "Something went wrong with removing files.\n"; unset TEMP_COLOR;
  exit 1
else
  TEMP_COLOR=lgreen; print_color "File removal completed OK.\n"; unset TEMP_COLOR;
fi
