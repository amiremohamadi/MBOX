#!/bin/bash
#a simple script that check mail inbox
#amir mohammadi :)

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
search=""

#------------------------------------
mailboxCheck() {
#Check if you used this before or not!
if  [ ! -e  "$directory""/mboxFile" ]; 
then 
#If you didn't use it before, this part get your informations to sing in
	echo "<SIGN IN>"
	read -p "Enter your username: " user
	echo "user:"$user  >> "$directory""/mboxFile"
	read -s -p "Enter your password [ Trust me:) ]: " pass
	echo  "pass:"$pass  >> "$directory""/mboxFile"
	echo $'\n-------------\nSettings finished!\n-------------'
	mailboxCheck
else
#Read user and pass from mboxFile
user=$(grep -oP "user:\K.*" "$directory""/mboxFile")
pass=$(grep -oP "pass:\K.*" "$directory""/mboxFile")
#If you used it before, this part read and show your inbox
curl -u $user:$pass --silent "https://mail.google.com/mail/feed/atom/all"| awk -F '<entry>' '{for (i=2; i<=NF; i++) {print $i}}'| grep "$search"| sed -n "s/<title>\(.*\)<\/title.*summary>\(.*\)<\/summary.*name>\(.*\)<\/name>.*/ ⬓ \3 : \1\n\n \2\n----------------------------- /p "
exit
fi
} 

#Flags
case $1 in
	"") mailboxCheck;;
	"-s" | "-S" | "--search") search=$2 ; mailboxCheck ;;
	"-h" | "--help") echo $'NAME\n       mbox - a command line for managing your Gmail box\n\nSYNOPSIS\n       mbox [OPTION]\n\nDESCRIPTION\n       -h : help\n       -s,-S,--search : search a word in your mails\nAUTHOR\n       AMIR MOHAMMADI :)';;
esac
