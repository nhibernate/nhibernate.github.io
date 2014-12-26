#!/bin/bash
for filename in $(find . -type f -iname "*\?*")
do 
  mv "$filename" "${filename//\?/%3F}" 
done