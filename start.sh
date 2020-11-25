#!/bin/bash

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------
#						ENVIROMENT VARIABLES
#-----------------------------------------------------------------------------------------------------------------------
export IGNORE_EVENTS_WHILE_COMMAND_IS_RUNNING=0

#Set mask of folder after each run
export UMASK=0000

export SETTLE_DURATION=10
export MAX_WAIT_TIME=01:00
export MIN_PERIOD=05:00

export DEBUG=0

export COMMAND "/config/filebot.sh"
export WATCH_DIR /input

#-----------------------------------------------------------------------------------------------------------------------

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
