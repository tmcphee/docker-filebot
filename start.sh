#!/bin/bash

function ts {
  echo [`date '+%b %d %X'`]
}

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
fi

echo "$(ts) Checking for config/filebot.sh"
if [ ! -f /config/filebot.sh ]
	then
		echo "$(ts) Creating /config/filebot.sh"
		cp /files/filebot.sh /config/filebot.sh
		chmod a+w /config/filebot.conf
	else
		echo "$(ts) config/filebot.sh Exists"
fi

# Run once at the start
echo "$(ts) Running FileBot auto-renamer on startup"
/config/filebot.sh

# Start monitoring
/files/monitor.py /config/filebot.conf