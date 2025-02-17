#!/bin/bash
# Script by Edward Stoever for Mariadb Support
unset ERR
DEC312199=7258032000
NW=$(date +%s)
SECONDS_UNTIL=$((($DEC312199 + 86400) - $NW))
DAYS_UNTIL=$(($SECONDS_UNTIL / 86400))
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
rm -f myCA.pem 2>/dev/null
openssl req -x509 -new -nodes -key myCA.key -sha256 -days $DAYS_UNTIL -out myCA.pem -config extensions.cfg -passin pass:mariadb || ERR=true

if [ $ERR ]; then
  echo "Something went wrong."
else
  echo "myCA.pem created successfully."
fi
