#!/bin/bash

# Begin Standard 'imports'
set -e
set -o pipefail

#######################################
# url encodes a provided string
# Globals:
#   None
# Arguments:
#   string: the raw string to url-encode
# Returns:
#   url-encoded string
#######################################
url_encode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}


#######################################
# decodes a provided url-encoded string
# Globals:
#   None
# Arguments:
#   string: a string to decode the url-encodings percent (%) signed codes
# Returns:
#   Returns a string in which the sequences with percent (%) signs followed by
#   two hex digits have been replaced with literal characters.
#######################################
urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//\%/\\x}"
}