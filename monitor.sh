#!/bin/bash

. /config/filebot.conf

function ts {
  echo [`date '+%b %d %X'`]
}

#-----------------------------------------------------------------------------------------------------------------------

# Run once at the start
echo "$(ts) Running FileBot auto-renamer on startup"
/config/filebot.sh

# Start monitoring
/files/monitor.py /config/filebot.conf
