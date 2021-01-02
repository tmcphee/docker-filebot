#!/bin/bash

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------
#						ENVIROMENT VARIABLES
#-----------------------------------------------------------------------------------------------------------------------
#Set mask of folder after each run
export UMASK=0000
export USER_ID=99
export GROUP_ID=100
#-----------------------------------------------------------------------------------------------------------------------

echo "$(ts) Checking Filesystem for filebot.sh"

echo "$(ts) Checking for config/filebot.sh"
if [ ! -f /config/filebot.sh ]
	then
		echo "$(ts) Creating /config/filebot.sh"
		cp /files/filebot.sh /config/filebot.sh
		chmod a+wx /config/filebot.sh
	else
		echo "$(ts) config/filebot.sh Exists"
		chmod a+wx /config/filebot.sh
fi

echo "$(ts) Checking for config/FileBot.conf"
if [ ! -f /config/filebot.sh ]
	then
		echo "$(ts) Creating /config/FileBot.conf"
		cp /files/filebot.sh /config/FileBot.conf
		chmod a+wx /config/FileBot.conf
	else
		echo "$(ts) config/FileBot.conf Exists"
		chmod a+wx /config/FileBot.conf
fi

# Set User mask
umask $UMASK

# Start monitoring
echo "$(ts) Starting FileBot Dir watcher"
/files/Watcher.py
