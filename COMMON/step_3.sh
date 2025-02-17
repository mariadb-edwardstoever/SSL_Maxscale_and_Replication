#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR

if [ ! -f vars.sh ]; then
  echo "vars.sh does not exist. Scripts must be run in the proper order. Exiting."; exit 1
fi

source ${SCRIPT_DIR}/functions.sh 
source ${SCRIPT_DIR}/vars.sh

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi

if [ ! "${RSA}" == "4096" ]; then RSA=2048; fi

################ TEST FILE CREATION
echo "test" > ${MY_ORGANIZATION}.txt
if [ -f ${MY_ORGANIZATION}.txt ]; then
  rm -f ${MY_ORGANIZATION}.txt
  TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR; 
else 
  TEMP_COLOR=lred; print_color "Something went wrong with test file creation.\n"; unset TEMP_COLOR; exit 1
fi

################ GENERATING NEW CA
if [ ! "$USE_PROVIDED_CA" == "YES" ]; then

if [ ! -f CA_configuration.cfg ]; then
  echo "CA_configuration.cfg does not exist. Scripts must be run in the proper order. Exiting."; exit 1
fi


if [ "$(cat CA_configuration.cfg | tr -d "[:space:]" | md5sum |  cut -d' ' -f1)" == "d1b5e8e0f709536916d377696208a325" ]; then
  TEMP_COLOR=lred; print_color "CA_configuration.cfg has not been edited.\nYou may want to edit that file.\nPress ";
  TEMP_COLOR=lcyan; print_color "c";
  TEMP_COLOR=lred; print_color " to continue with the fantasy company name in that file or press any other key to exit.\n"; unset TEMP_COLOR;
  read -s -n 1 RESPONSE
  if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
fi


# if the file exists but it is empty, remove it
if [ ! -s myCA.key ] && [ -f myCA.key ]; then rm -f myCA.key; fi
if [ -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A key file with name myCA.key already exists. "; unset TEMP_COLOR; print_color "Delete the file manually to continue.\nNothing done.\n"
exit 0
fi


TEMP_COLOR=lcyan; print_color "You must enter a passphrase for your key two times\n"
print_color "to generate the key and one additional time to generate the certificate.\n\n"
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

TEMP_COLOR=lcyan; print_color "Now enter the passphrase AGAIN for your key.\n\n"

openssl req -x509 -new -nodes -key myCA.key -sha256 -days ${HOW_MANY_DAYS_VALID} -out myCA.pem -config CA_configuration.cfg  || ERR=TRUE

if [ $ERR ]; then 
  TEMP_COLOR=lred; print_color "Something went wrong. Try again.\n"; unset TEMP_COLOR; 
  exit 0; 
else
  TEMP_COLOR=lcyan; print_color "OK!\n"; unset TEMP_COLOR; 
fi


################ USING PROVIDED CA
else

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
  TEMP_COLOR=lcyan; print_color "The passphrase for myCA.key is "; TEMP_COLOR=lmagenta; print_color "mariadb"; TEMP_COLOR=lcyan; print_color ".\n"; unset TEMP_COLOR; 
fi


fi
