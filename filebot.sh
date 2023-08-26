#!/bin/bash

# This script by default uses "Automated Media Center" (AMC). See the final filebot call below. For more docs on AMC,
# visit: http://www.filebot.net/forums/viewtopic.php?t=215

#-----------------------------------------------------------------------------------------------------------------------

INPUT_DIR="$1"
OUTPUT_DIR="$2"

#-----------------------------------------------------------------------------------------------------------------------

QUOTE_FIXER='replaceAll(/[\`\u00b4\u2018\u2019\u02bb]/, "'"'"'").replaceAll(/[\u201c\u201d]/, '"'"'""'"'"')'

# Customize the renaming format here. For info on formatting: https://www.filebot.net/naming.html

# music/Eric Clapton/From the Cradle/05 - It Hurts Me Too.mp3
MUSIC_FORMAT="music/{artist}/{album} ({y})/{pi.pad(2)} {t} - {artist} [{kbps}]"

# movies/Fight Club.mkv
MOVIE_FORMAT="movies/{n} ({y}) [{vf}] [{source}] [{ac} {channels}]/{n}"

# tv_shows/Game of Thrones/Season 05/Game of Thrones - S05E08 - Hardhome.mp4
SERIES_FORMAT="tv_shows/{n}/Season {s.pad(2)}/{n} - {s00e00} - {t}"

# Language code for file names
# en, de, es, ...
LANGUAGE="en"

# f.e. https://plex.domain.de:EQeDASSRWDFGGFxSSF
PLEX_API_KEY=""

# y or n
MUSIC=y

#-----------------------------------------------------------------------------------------------------------------------

# Used to detect old versions of this script
VERSION=6

# See http://www.filebot.net/forums/viewtopic.php?t=215 for details on amc
filebot \
  -script files/scripts/amc.groovy \
  -non-strict \
  "$INPUT_DIR" \
  --output "$OUTPUT_DIR" \
  --action move \
  --conflict skip \
  --lang="$LANGUAGE" \
  --def plex="$PLEX_API_KEY" \
  --def movieFormat="$MOVIE_FORMAT" \
  --def musicFormat="$MUSIC_FORMAT" \
  --def seriesFormat="$SERIES_FORMAT" \
  --def skipExtract=y \
  --def music="$MUSIC" \
  --def unsorted=y \
  --def ignore="Unsorted" \
  --def clean=y \
  --def storeReport="$OUTPUT_DIR"/reports
