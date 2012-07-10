#!/bin/bash

path_to="/home/cooler/wrk/cooler/git/scripts/home"
users_path="/home/cooler/wrk/cooler/git/scripts/users" #/var/cpanel/users/"
LOGFILE="/home/cooler/wrk/cooler/git/scripts/log"
DEBUG="1" #for enable uncomment line // disable -> comment line

for login in `ls -tr $users_path`; do

##	chown $login:nobody $path_to/$login

 if [[ -n "$DEBUG" ]]; then echo; echo; echo; echo "Processing $login" >> $LOGFILE;fi

### DIR
find "$path_to/$login" -type d -print0 | while read -d $'\0' dir; do 
if ( [[ $dir != *mail* ]] && [[ $dir != *etc* ]] && [[ $dir != *tmp* ]] && [[ $dir != *cgi-bin* ]] ); then 
    stat=`stat -c %a "$dir"`
 if ( [[ $stat != 755 ]] ); then 
	     if [[ -n "$DEBUG" ]]; then echo "Directory $dir has !755 perms!!" >> $LOGFILE;fi
	chmod 755 "$dir";
 fi
echo -n;fi; done 
###/DIR

	chmod 711 $path_to/$login

### FILE
find "$path_to/$login" -type f -print0 | while read -d $'\0' file; do 
if ( [[ $file != *mail* ]] && [[ $file != *etc* ]] && [[ $file != *tmp* ]] && [[ $file != *cgi-bin* ]] ); then 
    stat=`stat -c %a "$file"`
    if (( $stat != 664 )); then 
	     if [[ -n "$DEBUG" ]]; then echo "File $file has !644 perms!!" >> $LOGFILE;fi
	chmod 664 "$file"; 
    fi
echo -n;fi; done 
### /FILE

 if [[ -n "$DEBUG" ]]; then echo "Processing $login DONE" >> $LOGFILE;fi
 if [[ -n "$DEBUG" ]]; then echo "======================" >> $LOGFILE;fi 

echo -n;done





