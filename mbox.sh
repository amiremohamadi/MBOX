#!/bin/bash
#a simple script that check mail inbox
#amir mohammadi :)

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
configFile="${directory}/.mboxFile"
dlFile="${directory}/.dlFile"
search=""

#------------------------------------
mailboxCheck() {
#Check if you used this before or not!
if  [ ! -r  ${configFile} ]; 
then 
#If you didn't use it before, this part get your informations to sign in

        #Set file to viewable only by you
        touch ${configFile}
        chmod 600 ${configFile}
	echo "<SIGN IN>"
	read -p "Enter your username: " user
	echo "user:"$user  >> ${configFile}
	read -s -p "Enter your password [ Trust me:) ]: " pass
	echo  "pass:"$pass  >> ${configFile} 
	echo $'\n-------------\nSettings finished!\n-------------'
	mailboxCheck
else
    #Read user and pass from mboxFile
    user=$(grep -oP "user:\K.*" ${configFile})
    pass=$(grep -oP "pass:\K.*" ${configFile})
    #If you used it before, this part reads and show your inbox
    curl  --silent -u $user:$pass "https://mail.google.com/mail/feed/atom/all" > ${dlFile}
    
    unauth='<H1>Unauthorized</H1>'
    grep  "${unauth}" ${dlFile} ;
    if [ $? ] ; then 
        printf "ERROR: Unauthorized access to account.\n "
        exit 1
    fi
    
    cat ${dlFile} | awk -F '<entry>' '{for (i=2; i<=NF; i++) {print $i}}'| grep "$search"| sed -n "s/<title>\(.*\)<\/title.*summary>\(.*\)<\/summary.*name>\(.*\)<\/name>.*/ ⬓ \3 : \1\n\n \2\n----------------------------- /p "
    echo $?
    exit
fi
} 

#Flags
case $1 in
	"") mailboxCheck;;
	"-s" | "-S" | "--search") search=$2 ; mailboxCheck ;;
	"-h" | "--help") echo $'NAME\n       mbox - a command line for managing your Gmail box\n\nSYNOPSIS\n       mbox [OPTION]\n\nDESCRIPTION\n       -h : help\n       -s,-S,--search : search a word in your mails\nAUTHOR\n       AMIR MOHAMMADI :)';;
esac
