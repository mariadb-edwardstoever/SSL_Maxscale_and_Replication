#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR SKIP_NEW_CSR PROVIDED_KEY_IN_USE
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh

MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')

if [ ! -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A key file does not exist. "; unset TEMP_COLOR; print_color "Nothing done.\n"
  exit 0
fi

if [ ! -f myCA.pem ]; then
  TEMP_COLOR=lred; print_color "A CA pem file does not exist. "; unset TEMP_COLOR; print_color "Nothing done.\n"
exit 0
fi

if [ ! -f ${MY_ORGANIZATION}.key ]; then
  TEMP_COLOR=lred; print_color "A key file ${MY_ORGANIZATION}.key does not exist. Run the script create_own_key.sh first.\n"; unset TEMP_COLOR; print_color "Nothing done.\n"
exit 0
fi

if [ "$(cat OWN_org_details.cfg | tr -d "[:space:]" | md5sum |  cut -d' ' -f1)" == "f91a183804da859620e5c1ef6e4dfb52" ]; then
  TEMP_COLOR=lred; print_color "OWN_org_details.cfg has not been edited.\nYou definitely want to edit that file.\nPress "; 
  TEMP_COLOR=lcyan; print_color "c"; 
  TEMP_COLOR=lred; print_color " to continue with a fantasy company name or any other key to exit.\n"; unset TEMP_COLOR;
  read -s -n 1 RESPONSE
  if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
fi

echo "---"

if [ -f "${MY_ORGANIZATION}.csr" ]; then
  TEMP_COLOR=lred;  print_color "The Cert Signing Request file ${MY_ORGANIZATION}.csr exists.\nPress "; 
  TEMP_COLOR=lcyan; print_color "u"; 
  TEMP_COLOR=lred;  print_color " to use the existing file or press "; 
  TEMP_COLOR=lcyan; print_color "c";
  TEMP_COLOR=lred;  print_color " to create a new file. Any other key will exit.\n";
  read -s -n 1 RESPONSE
  if [ "$RESPONSE" = "c" ]; then rm -f ${MY_ORGANIZATION}.csr; printf "File removed. OK.\n"; fi
  if [ "$RESPONSE" = "u" ]; then printf "Continuing with existing CSR file.\n"; SKIP_NEW_CSR=TRUE; fi
  if [ ! "$RESPONSE" = "c" ] && [ ! "$RESPONSE" = "u" ]; then printf "Nothing done.\n"; exit 0; fi
fi 

echo "---"

if [ ! $SKIP_NEW_CSR ]; then
  TEMP_COLOR=lcyan; print_color "Creating a Certificate signing Request for your organization.\n"; unset TEMP_COLOR;
  openssl req -new -key ${MY_ORGANIZATION}.key -out ${MY_ORGANIZATION}.csr -config OWN_org_details.cfg || ERR=true
  if [ $ERR ]; then
    TEMP_COLOR=lred; print_color "Something went wrong with creating the Certificate Signing Request.\n"; unset TEMP_COLOR;
    exit 1
  else
    TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
  fi
fi

echo "---"


if [ -f "${MY_ORGANIZATION}.crt" ]; then
  TEMP_COLOR=lred;  print_color "A Signed Certificate file ${MY_ORGANIZATION}.crt already exists.\nPress "; 
  TEMP_COLOR=lcyan; print_color "c";
  TEMP_COLOR=lred;  print_color " to delete the old file and create a new file.\nAny other key will exit.\n";
  read -s -n 1 RESPONSE
  if [ "$RESPONSE" = "c" ]; then rm -f ${MY_ORGANIZATION}.crt; printf "File removed. OK.\n"; fi
  if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
fi 

echo "---"

if [ "$(md5sum myCA.key | awk '{print $1}')" == "24a044e4a0d8e0467105cb6a3784401d" ]; then
  PROVIDED_KEY_IN_USE=TRUE;
fi

TEMP_COLOR=lcyan; print_color "Creating a Signed Certificate for your organization.\n"; unset TEMP_COLOR; 

if [ $PROVIDED_KEY_IN_USE ]; then
  openssl x509 -req -in ${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out ${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile OWN_extensions.cfg -passin pass:mariadb || ERR=true
else
  TEMP_COLOR=lcyan; print_color "You will need to type the pass phrase for myCA.key.\n"; unset TEMP_COLOR;
  openssl x509 -req -in ${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out ${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile OWN_extensions.cfg || ERR=true
fi

if [ $ERR ]; then
  TEMP_COLOR=lred; print_color "Something went wrong with creating the Signed Certificate Request.\n"; unset TEMP_COLOR;
  exit 1
else
  TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
  ln ${MY_ORGANIZATION}.crt ${MY_ORGANIZATION}.pem
fi



