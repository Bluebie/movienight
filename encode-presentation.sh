#!/bin/bash
preset="${3:-fast}"
pubdir="./web/public/presentation/$2"
frameinterval="8"
hls_options="-hls_list_size 0 -hls_time $frameinterval -hls_init_time $frameinterval"

echo "Generating a new HLS presentation $2"
echo "Source: $1"
echo "clearing presentation folder..."
rm -r $pubdir
mkdir $pubdir
echo "generating manifest..."

manifest="$pubdir/stream.m3u8"
echo "#EXTM3U" > $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=596000,RESOLUTION=432x243,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream400x596k.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1328000,RESOLUTION=720x405,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream720x1328k.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2128000,RESOLUTION=1024x576,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream1024x2128k.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=3192000,RESOLUTION=1280x720,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream1280x3192k.m3u8" >> $manifest

echo "encoding streams..."
ffmpeg -i "$1" \
  -force_key_frames "expr:gte(t,n_forced*$frameinterval)" -c:v libx264 -preset "$preset" -vprofile main -sn -vlevel 3.1 -vf scale=432:-2  -b:v 500k  -c:a libfdk_aac -ar 44100 -ac 2 -b:a 96k  $hls_options "$pubdir/stream400x596k.m3u8" \
  -force_key_frames "expr:gte(t,n_forced*$frameinterval)" -c:v libx264 -preset "$preset" -vprofile main -sn -vlevel 3.1 -vf scale=720:-2  -b:v 1200k -c:a libfdk_aac -ar 44100 -ac 2 -b:a 128k $hls_options "$pubdir/stream720x1328k.m3u8" \
  -force_key_frames "expr:gte(t,n_forced*$frameinterval)" -c:v libx264 -preset "$preset" -vprofile main -sn -vlevel 3.1 -vf scale=1024:-2 -b:v 2000k -c:a libfdk_aac -ar 44100 -ac 2 -b:a 128k $hls_options "$pubdir/stream1024x2128k.m3u8" \
  -force_key_frames "expr:gte(t,n_forced*$frameinterval)" -c:v libx264 -preset "$preset" -vprofile main -sn -vlevel 3.1 -vf scale=1280:-2 -b:v 3000k -c:a libfdk_aac -ar 44100 -ac 2 -b:a 192k $hls_options "$pubdir/stream1280x3192k.m3u8"
