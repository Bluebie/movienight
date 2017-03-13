#!/bin/bash
preset="${3:-veryfast}"
pubdir="./presentation/$2"
frameinterval="8"
video_settings="-force_key_frames expr:gte(t,n_forced*$frameinterval) -c:v libx264 -preset $preset -vprofile main -sn -vlevel 3.1"
audio_settings="-c:a libfdk_aac -ar 44100 -ac 2"
hls_options="-hls_flags delete_segments -hls_time $frameinterval -hls_init_time $frameinterval"
extra_args="${4}" # useful for changing framerate "-r 30", etc

echo "Generating a new live HLS stream $2"
echo "Source file: $1"
echo "Clearing stream folder..."
rm -r $pubdir
echo "Generating manifest..."

mkdir $pubdir
manifest="$pubdir/stream.m3u8"
echo "#EXTM3U" > $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=596000,RESOLUTION=432x243,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream-A-.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1328000,RESOLUTION=720x405,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream-B-.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2128000,RESOLUTION=1024x576,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream-C-.m3u8" >> $manifest
echo "#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=3192000,RESOLUTION=1280x720,CODECS=\"avc1.4D401f,mp4a.40.2\"" >> $manifest
echo "stream-D-.m3u8" >> $manifest

echo "Streaming..."
ffmpeg -re -i "$1" \
  $extra_args $video_settings -vf scale=432:-2  -b:v 500k  $audio_settings -ac 2 -b:a 96k  $hls_options "$pubdir/stream-A-.m3u8" \
  $extra_args $video_settings -vf scale=720:-2  -b:v 1200k $audio_settings -ac 2 -b:a 128k $hls_options "$pubdir/stream-B-.m3u8" \
  $extra_args $video_settings -vf scale=1024:-2 -b:v 2000k $audio_settings -ac 2 -b:a 128k $hls_options "$pubdir/stream-C-.m3u8" \
  $extra_args $video_settings -vf scale=1280:-2 -b:v 3000k $audio_settings -ac 2 -b:a 192k $hls_options "$pubdir/stream-D-.m3u8"

echo "Stream complete, waiting 60 seconds for everyone to finish stream..."
sleep 60
echo "Erasing stream files..."
rm -r "$pubdir"
echo "All done!"
