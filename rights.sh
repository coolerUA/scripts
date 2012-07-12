#!/bin/bash

VERSION="0.7"
RPEV="0.6"

renice -n +20 -p $$ 2>&1 >/dev/null
set -o nounset
set -o errexit

### VARIABLE DEFINE 
SELF=$(basename $0)
UPDATE_BASE=https://raw.github.com/zcooler/scripts/master/
path_to="/home"
users_path="/var/cpanel/users"
LOGFILE="/var/log/rights/`date +%F--%H-%M`.log"
DEBUG="1" #for enable uncomment line // disable -> comment line
FILE_PERM="644"
DIR_PERM="755"
EXEC_PERM="750"


### /VARIABLE DEFINE


 if [[ -n "$DEBUG" ]]; then echo; echo; echo; echo "Starting @ `date +%F--%H-%M`" >> $LOGFILE;fi

for login in `ls -tr $users_path`; do

 if [[ -n "$DEBUG" ]]; then echo; echo; echo; echo "Processing $login" >> $LOGFILE;fi

search="$path_to/$login"

### DIR
find "$search" -type d -print0 | while read -d $'\0' dir; do 
if ( [[ $dir != *mail* ]] && [[ $dir != *etc* ]] && [[ $dir != *tmp* ]] && [[ $dir != *cgi-bin* ]] && [[ $dir != "/home/$login/virtualenv*" ]]  && [[ $dir != "/home/$login/ruby*" ]]); then 
    stat=`stat -c %a "$dir"`
    if ( [[ $stat != $DIR_PERM ]] ); then 
	     if [[ -n "$DEBUG" ]]; then echo "Directory $dir has ! $DIR_PERM perms!!" >> $LOGFILE;fi
	chmod $DIR_PERM "$dir";
    fi;
fi; done 
###/DIR

### FILE
find "$search" -type f -print0 | while read -d $'\0' file; do 
if ( [[ $file != *mail* ]] && [[ $file != *etc* ]] && [[ $file != *tmp* ]] && [[ $file != *cgi-bin* ]] && [[ $file != *.pl ]] && [[ $file != *.cgi ]] && [[ $file != *.wsgi ]] && [[ $file != *.sh ]] && [[ $dir != "/home/$login/virtualenv*" ]]  && [[ $dir != "/home/$login/ruby*" ]] ); then 
    stat=`stat -c %a "$file"`
    if ([[ $stat != $FILE_PERM ]]); then 
        if ( [[ $file != *.sh ]] || [[ $stat != $EXEC_PERM ]] ); then 
	    if [[ -n "$DEBUG" ]]; then echo "File $file has !$FILE_PERM || !$EXEC_PERM perms!!" >> $LOGFILE;fi
	    chmod $FILE_PERM "$file";
	fi
	if ([[ -n "$DEBUG" ]] && [[ $file != *.sh ]]) ; then echo "File $file has !$FILE_PERM perms!!" >> $LOGFILE;fi
    fi;
fi; done 
### /FILE

### MISC PERMS
	chown $login:nobody $path_to/$login/public_html
	chmod 711 $path_to/$login
	chmod $EXEC_PERM $path_to/$login/public_html
### /MISC PREMS

 if [[ -n "$DEBUG" ]]; then echo "Processing $login DONE" >> $LOGFILE;fi
 if [[ -n "$DEBUG" ]]; then echo "======================" >> $LOGFILE;fi

echo -n;done

runSelfUpdate() {
  if ! wget --quiet --output-document="$0.tmp" $UPDATE_BASE/$SELF ; then
    exit 1
  fi
  OCTAL_MODE=$(stat -c '%a' $SELF)
  if ! chmod $OCTAL_MODE "$0.tmp" ; then
    exit 1
  fi
  cat > updateScript.sh << EOF
#!/bin/bash
if mv "$0.tmp" "$0"; then
  rm \$0
else
  echo "Failed!"
fi
EOF
  exec /bin/bash updateScript.sh
}
SUM_LATEST=$(curl -s $UPDATE_BASE/$SELF | grep VERSION -m 1 |awk -F\" '{ print $2}')
SUM_SELF=$(cat $0 | grep VERSION -m 1 |awk -F\" '{ print $2}')
if [[ "$SUM_LATEST" != "$SUM_SELF" ]]; then
     if [[ -n "$DEBUG" ]]; then echo "NOTE: New version available! Updating..." >> $LOGFILE;fi
  runSelfUpdate
fi

