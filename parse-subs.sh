#!/bin/bash
pubdir="web/public/presentation/$2"

echo "Parsing Subtitles from source"
index="-1"
streamtype="na"
NL=$'\n'
subtitlesFile="$pubdir/subtitles.txt"

rm $subtitlesFile

ffprobe -loglevel fatal -show_streams "$1" > mediainfo.txt
while read line; do
  if echo "$line" | grep -q "index="; then
    index=`echo "$line" | grep --only-matching "[0-9]"`;
  fi
  if echo "$line" | grep -q "codec_type="; then
    streamtype=`echo "$line" | sed -n -e 's/^.*codec_type=//p'`
  fi
  if echo "$line" | grep -q "TAG:language="; then
    sublang=`echo "$line" | sed -n -e 's/^.*TAG:language=//p'`
  fi
  if echo "$line" | grep -q "\[/STREAM\]"; then
    echo "Track $index is $streamtype and language is $sublang"
    if [[ $streamtype = "subtitle" ]]; then
      #submaps="$submaps -map 0:$index"
      echo "stream_subtitles_${index}.vtt=${sublang}" >> $subtitlesFile
      echo "extracting $sublang subtitles..."
      ffmpeg -nostats -loglevel error -i "$1" -map "0:$index" -y "$pubdir/stream_subtitles_$index.vtt"
    fi
    index="-1"
    streamtype="na"
    sublang="na"
  fi
done <mediainfo.txt

rm mediainfo.txt
