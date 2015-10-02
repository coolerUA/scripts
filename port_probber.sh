#!/bin/bash

# (c) cooler
# port prober

# settings
SLEEP="2" # sleep between checks in seconds
NC_TIMEOUT="2" # connect timeout in seconds


if [ $1 = "-h" ] || [ $1 = "--help" ]
then
echo -e "Usage:\n $0 4.4.4.4 80 \n or \n $0 google.com 8080"
exit
fi

PORT=$2
if [ ! $2 ] 
then
echo -e "Missing port! Using 80 as default"
PORT=80
fi

# variables
HOST=$1
ALL="0"
FAILED="0"
OK="0"

print_stat() {
    echo -ne "\033[2KTry # $ALL  on $HOST port $PORT at "$(date +"%H:%M:%S %D") "[ OK $OK | FAILED $(($ALL-$OK)) ]\r"
}

inc_ok() { 
    print_stat;let OK=OK+1
}
inc_fail() { 
    print_stat;let FAILED=FAILED+1
}

while true; do 
trap 'echo -e "\nEnding... \r\n\n Total tryes: # [TOTALL $ALL | OK $OK| FAILED $(($ALL-$OK))]"; exit' SIGINT SIGQUIT
echo -e "GET / HTTP/1.0\n\n" | nc -w $NC_TIMEOUT $HOST $PORT >/dev/null && inc_ok ||  inc_fail
sleep $SLEEP
let ALL=ALL+1
echo -n;done
