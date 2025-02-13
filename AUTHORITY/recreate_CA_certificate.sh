#!/bin/bash
# Script by Edward Stoever for Mariadb Support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
rm -f myCA.pem 2>/dev/null
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 9999 -out myCA.pem -config extensions.cfg
