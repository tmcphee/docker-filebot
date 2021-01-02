#!/bin/bash

# Check if script is already stared
if [ -v "${STARTED}" ]; then
	exit 0
fi

export STARTED=1

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

# Set User mask
umask $UMASK

# Start monitoring
echo "$(ts) Starting FileBot Dir watcher"
/files/Watcher.py
