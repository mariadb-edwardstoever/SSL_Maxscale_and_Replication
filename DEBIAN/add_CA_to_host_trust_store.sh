#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
source ${SCRIPT_DIR}/functions.sh
source ${SCRIPT_DIR}/vars.sh
MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')


unset ERR
get_linux_type;

if [ ! "${LINUX_TYPE}" == "DEBIAN" ]; then
  echo "This does not appear to be Debian GNU/Linux. Exiting."; exit 1
fi


if [ ! -f myCA.pem ]; then
  TEMP_COLOR=lred; print_color "The file myCA.pem does not exist in $SCRIPT_DIR. "; unset TEMP_COLOR; print_color "\nNothing done.\n"
exit 1
fi

if [ ! -d /etc/pki/ca-trust/source/anchors ]; then 
 TEMP_COLOR=lred; print_color "The directory /etc/pki/ca-trust/source/anchors does not exist. "; unset TEMP_COLOR; print_color "\nNothing done.\n"
 exit 1
fi

cp myCA.pem /etc/pki/ca-trust/source/anchors/ || ERR=true
update-ca-trust extract || ERR=true

if [ ${ERR} ]; then
  TEMP_COLOR=lred; print_color "Something went wrong.\n"; exit 1
else
  TEMP_COLOR=lgreen; print_color "myCA added to trust store.\n"; unset TEMP_COLOR;
fi

# This command will verify against trust store
openssl verify ./${MY_ORGANIZATION}.pem


