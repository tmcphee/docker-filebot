#!/bin/bash

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------

IGNORE_EVENTS_WHILE_COMMAND_IS_RUNNING=0

USER_ID=99
GROUP_ID=100
UMASK=0000
COMMAND "/config/filebot.sh"
WATCH_DIR /input

echo "$(ts) Starting FileBot container"

echo "$(ts) Checking for config/filebot.conf"
if [ ! -f /config/filebot.conf ]
	then
		echo "$(ts) Creating /config/filebot.conf"
		cp /files/filebot.conf /config/filebot.conf
		chmod a+w /config/filebot.conf
	else
		echo "$(ts) config/filebot.conf Exists"
		chmod a+w /config/filebot.conf
fi

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

# Run once at the start
echo "$(ts) Running FileBot auto-renamer on startup"
/files/runas.sh $USER_ID $GROUP_ID $UMASK /config/filebot.sh

# Start monitoring
/files/monitor.py /config/filebot.conf
