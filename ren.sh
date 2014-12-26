#!/bin/bash
for filename in $(find . -type d -iname "*\\\"*")
do 
  rm -rd "$filename" 
done