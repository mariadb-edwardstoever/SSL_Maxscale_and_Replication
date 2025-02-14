#!/usr/bin/env bash
# Script by Edward Stoever for Mariadb Support

function print_color () {
  if [ -z "$TEMP_COLOR" ]; then printf "$1"; return; fi
if [ $TEMP_COLOR ]; then
  case "$TEMP_COLOR" in
    default) i="0;36" ;; red)  i="0;31" ;; blue) i="0;34" ;; green) i="0;32" ;; yellow) i="0;33" ;; magenta) i="0;35" ;; cyan) i="0;36" ;; lred) i="1;31" ;; lblue) i="1;34" ;; lgreen) i="1;32" ;; lyellow) i="1;33" ;; lmagenta) i="1;35" ;; lcyan) i="1;36" ;; *) i="0" ;;
  esac
fi
  printf "\033[${i}m${1}\033[0m"
}


function get_linux_type () {
  LINUX_TYPE=$(cat /etc/os-release | grep PRETTY |cut -d\" -f2 | head -c 7 | sed "s/ //g"| tr '[:lower:]' '[:upper:]')
}
