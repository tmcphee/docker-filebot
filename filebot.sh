#!/bin/bash

# This script by default uses "Automated Media Center" (AMC). See the final filebot call below. For more docs on AMC,
# visit: http://www.filebot.net/forums/viewtopic.php?t=215

#-----------------------------------------------------------------------------------------------------------------------

INPUT_DIR=%1
OUTPUT_DIR=%2

#-----------------------------------------------------------------------------------------------------------------------

QUOTE_FIXER='replaceAll(/[\`\u00b4\u2018\u2019\u02bb]/, "'"'"'").replaceAll(/[\u201c\u201d]/, '"'"'""'"'"')'

# Customize the renaming format here. For info on formatting: https://www.filebot.net/naming.html

# Music/Eric Clapton/From the Cradle/05 - It Hurts Me Too.mp3
MUSIC_FORMAT="MUSIC/{artist}/{album} ({y})/{pi.pad(2)} {t} - {artist} [{kbps}]"

# Movies/Fight Club.mkv
MOVIE_FORMAT="MOVIES/{n} ({y}) [{vf}] [{source}] [{ac} {channels}]/{n}"

# TV Shows/Game of Thrones/Season 05/Game of Thrones - S05E08 - Hardhome.mp4
# TV Shows/Game of Thrones/Special/Game of Thrones - S00E11 - A Day in the Life.mp4
SERIES_FORMAT="TV/{n}/Season {s.pad(2)}/{n} - {s00e00} - {t}"

#-----------------------------------------------------------------------------------------------------------------------

# Used to detect old versions of this script
VERSION=5

# See http://www.filebot.net/forums/viewtopic.php?t=215 for details on amc
filebot -script files/scripts/amc.groovy -no-xattr --output "$OUTPUT_DIR" --log-file /files/amc.log --action move --conflict auto \
  -non-strict --def ut_dir="$INPUT_DIR" ut_kind=multi music=y deleteAfterExtract=y clean=y \
  excludeList=/config/amc-exclude-list.txt \
  movieFormat="$MOVIE_FORMAT" musicFormat="$MUSIC_FORMAT" seriesFormat="$SERIES_FORMAT"

if [ "$ALLOW_REPROCESSING" = "yes" ]; then
  tempfile=$(mktemp)
  # FileBot only puts files that it can process into the amc-exclude-list.txt file. e.g. jpg files are not in there. So
  # take the intersection of the existing files and the ones in the list.
  comm -12 <(sort /config/amc-exclude-list.txt) <(find /input | sort) > $tempfile
  mv -f $tempfile /config/amc-exclude-list.txt
fi
