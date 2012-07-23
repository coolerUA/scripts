#!/bin/bash

search="./"
prev="0"
LOG=./`date +%F--%H-%M`.log

find $search -type l -print0 | while read -d $'\0' files; do
    folder=`echo $files | awk 'BEGIN{FS=OFS="/"}{$NF=""; NF--; print}'`
    if [ $prev == $folder ]; then echo "FOUND!!! [$folder]: "`find $folder -type l `"">>$LOG ;fi
    prev=$(echo $folder);
done