#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
unset ERR

if [ ! -f vars.sh ]; then
  echo "vars.sh does not exist. Scripts must be run in the proper order. Exiting."; exit 1
fi

source ${SCRIPT_DIR}/vars.sh
source ${SCRIPT_DIR}/functions.sh

if [ "$(basename $SCRIPT_DIR)" == "COMMON" ]; then
  TEMP_COLOR=lred; print_color "Do not run scripts from the COMMON directory. "; unset TEMP_COLOR; print_color "Exiting.\n\n"; exit 1;
fi

if [ ! -f myCA.key ]; then
  TEMP_COLOR=lred; print_color "A CA key file does not exist. Run the script Certificate_Authority.sh first.\n"; unset TEMP_COLOR; print_color "Nothing done.\n\n"
  exit 0
fi

if [ ! -f myCA.pem ]; then
  TEMP_COLOR=lred; print_color "A CA pem file does not exist.  Run the script Certificate_Authority.sh first.\n"; unset TEMP_COLOR; print_color "Nothing done.\n\n"
exit 0
fi

if [ ! "${RSA}" == "4096" ]; then RSA=2048; fi

# remove spaces if exist from MY_ORGANIZATION
MY_ORGANIZATION=$(echo ${MY_ORGANIZATION} | sed 's/ //g')

################ TEST FILE CREATION
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

openssl genrsa -out ${MY_ORGANIZATION}.key ${RSA} || ERR=TRUE

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


if [ "$GENERATE_ALL_PURPOSE_CERTIFICATE" == "YES" ]; then

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

   if [ "$(cat OWN_all-purpose_extensions.cfg | tr -d "[:space:]" | md5sum |  cut -d' ' -f1)" == "fd45330401b89347addaee02dceb7841" ]; then
     TEMP_COLOR=lred; print_color "OWN_all-purpose_extensions.cfg has not been edited.\nYou definitely want to edit the DNS.1 section of that file.\nPress "; 
     TEMP_COLOR=lcyan; print_color "c"; 
     TEMP_COLOR=lred; print_color " to continue with a fantasy company name or any other key to exit.\n"; unset TEMP_COLOR;
     read -s -n 1 RESPONSE
     if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
   fi

   if [ ! $SKIP_NEW_CSR ]; then
     TEMP_COLOR=lcyan; print_color "Creating a Certificate signing Request for all-purpose certificate.\n"; unset TEMP_COLOR;
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
     openssl x509 -req -in ${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out ${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile OWN_all-purpose_extensions.cfg -passin pass:mariadb || ERR=true
   else
     TEMP_COLOR=lcyan; print_color "You will need to type the pass phrase for myCA.key.\n"; unset TEMP_COLOR;
     openssl x509 -req -in ${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out ${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile OWN_all-purpose_extensions.cfg || ERR=true
   fi

   if [ $ERR ]; then
     TEMP_COLOR=lred; print_color "Something went wrong with creating the Signed Certificate.\n"; unset TEMP_COLOR;
     exit 1
   else
     TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
     rm -f ${MY_ORGANIZATION}.pem 2>/dev/null; ln ${MY_ORGANIZATION}.crt ${MY_ORGANIZATION}.pem
   fi
else
  TEMP_COLOR=lcyan; print_color "Creation of all-purpose certifcate skippped.\n"; unset TEMP_COLOR;
fi

if [ "$GENERATE_SERVER_CERTIFICATE" == "YES" ]; then

   if [ -f "server_${MY_ORGANIZATION}.csr" ]; then
     TEMP_COLOR=lred;  print_color "The Cert Signing Request file server_${MY_ORGANIZATION}.csr exists.\nPress "; 
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
     TEMP_COLOR=lcyan; print_color "Creating a Certificate signing Request for server certificate.\n"; unset TEMP_COLOR;
     openssl req -new -key ${MY_ORGANIZATION}.key -out server_${MY_ORGANIZATION}.csr -config OWN_org_details.cfg || ERR=true
       if [ $ERR ]; then
         TEMP_COLOR=lred; print_color "Something went wrong with creating the Server Certificate Signing Request.\n"; unset TEMP_COLOR;
         exit 1
       else
         TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
       fi
   fi

   echo "---"

   if [ -f "${MY_ORGANIZATION}.crt" ]; then
     TEMP_COLOR=lred;  print_color "A Signed Certificate file server_${MY_ORGANIZATION}.crt already exists.\nPress "; 
     TEMP_COLOR=lcyan; print_color "c";
     TEMP_COLOR=lred;  print_color " to delete the old file and create a new file.\nAny other key will exit.\n";
     read -s -n 1 RESPONSE
     if [ "$RESPONSE" = "c" ]; then rm -f server_${MY_ORGANIZATION}.crt; printf "File removed. OK.\n"; fi
     if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
   fi 

   echo "---"

   if [ "$(md5sum myCA.key | awk '{print $1}')" == "24a044e4a0d8e0467105cb6a3784401d" ]; then
     PROVIDED_KEY_IN_USE=TRUE;
   fi

   TEMP_COLOR=lcyan; print_color "Creating a Signed Certificate for your organization's servers.\n"; unset TEMP_COLOR; 


   if [ "${INCLUDE_SERVERAUTH_FLAG}" == "YES" ]; then
     printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\nextendedKeyUsage=serverAuth\n" > tmp_ext.cfg
   else
     printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\n" > tmp_ext.cfg
   fi 

   if [ $PROVIDED_KEY_IN_USE ]; then
     openssl x509 -req -in server_${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out server_${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile tmp_ext.cfg -passin pass:mariadb || ERR=true
   else
     TEMP_COLOR=lcyan; print_color "You will need to type the pass phrase for myCA.key.\n"; unset TEMP_COLOR;
     openssl x509 -req -in server_${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out server_${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile tmp_ext.cfg || ERR=true
   fi

   if [ $ERR ]; then
     TEMP_COLOR=lred; print_color "Something went wrong with creating the Server Signed Certificate.\n"; unset TEMP_COLOR;
     exit 1
   else
     TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
     rm -f server_${MY_ORGANIZATION}.pem 2>/dev/null; ln server_${MY_ORGANIZATION}.crt server_${MY_ORGANIZATION}.pem
   fi
   
   rm -f tmp_ext.cfg 2>/dev/null

else
  TEMP_COLOR=lcyan; print_color "Creation of server certifcate skippped.\n"; unset TEMP_COLOR;
fi


if [ "$GENERATE_CLIENT_CERTIFICATE" == "YES" ]; then
   if [ -f "client_${MY_ORGANIZATION}.csr" ]; then
     TEMP_COLOR=lred;  print_color "The Cert Signing Request file client_${MY_ORGANIZATION}.csr exists.\nPress "; 
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
     TEMP_COLOR=lcyan; print_color "Creating a Certificate signing Request for client certificate.\n"; unset TEMP_COLOR;
     openssl req -new -key ${MY_ORGANIZATION}.key -out client_${MY_ORGANIZATION}.csr -config OWN_org_details.cfg || ERR=true
       if [ $ERR ]; then
         TEMP_COLOR=lred; print_color "Something went wrong with creating the Client Certificate Signing Request.\n"; unset TEMP_COLOR;
         exit 1
       else
         TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
       fi
   fi

   echo "---"

   if [ -f "${MY_ORGANIZATION}.crt" ]; then
     TEMP_COLOR=lred;  print_color "A Signed Certificate file client_${MY_ORGANIZATION}.crt already exists.\nPress "; 
     TEMP_COLOR=lcyan; print_color "c";
     TEMP_COLOR=lred;  print_color " to delete the old file and create a new file.\nAny other key will exit.\n";
     read -s -n 1 RESPONSE
     if [ "$RESPONSE" = "c" ]; then rm -f client_${MY_ORGANIZATION}.crt; printf "File removed. OK.\n"; fi
     if [ ! "$RESPONSE" = "c" ]; then printf "Nothing done.\n"; exit 0; fi
   fi 

   echo "---"

   if [ "$(md5sum myCA.key | awk '{print $1}')" == "24a044e4a0d8e0467105cb6a3784401d" ]; then
     PROVIDED_KEY_IN_USE=TRUE;
   fi

   TEMP_COLOR=lcyan; print_color "Creating a Signed Certificate for your organization's clients.\n"; unset TEMP_COLOR; 


   if [ "${INCLUDE_CLIENTAUTH_FLAG}" == "YES" ]; then
     printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\nextendedKeyUsage=clientAuth\n" > tmp_ext.cfg
   else
     printf "authorityKeyIdentifier=keyid,issuer\nbasicConstraints=CA:FALSE\nkeyUsage=digitalSignature,nonRepudiation,keyEncipherment,dataEncipherment\n" > tmp_ext.cfg
   fi 

   if [ $PROVIDED_KEY_IN_USE ]; then
     openssl x509 -req -in client_${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out client_${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile tmp_ext.cfg -passin pass:mariadb || ERR=true
   else
     TEMP_COLOR=lcyan; print_color "You will need to type the pass phrase for myCA.key.\n"; unset TEMP_COLOR;
     openssl x509 -req -in client_${MY_ORGANIZATION}.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out client_${MY_ORGANIZATION}.crt -days ${HOW_MANY_DAYS_VALID} -sha256 -extfile tmp_ext.cfg || ERR=true
   fi

   if [ $ERR ]; then
     TEMP_COLOR=lred; print_color "Something went wrong with creating the Client Signed Certificate.\n"; unset TEMP_COLOR;
     exit 1
   else
     TEMP_COLOR=lgreen; print_color "OK\n"; unset TEMP_COLOR;
     rm -f client_${MY_ORGANIZATION}.pem 2>/dev/null; ln client_${MY_ORGANIZATION}.crt client_${MY_ORGANIZATION}.pem
   fi
   
   rm -f tmp_ext.cfg 2>/dev/null

else
  TEMP_COLOR=lcyan; print_color "Creation of client certifcate skippped.\n"; unset TEMP_COLOR;
fi
