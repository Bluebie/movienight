MovieNight is a little project I built to do preview screenings of video stuff.
It's just a couple of bash scripts and static html. It uses similar streaming
tech to netflix/youtube/whatever to do adaptive streaming up to 720p by default.

Usually I feed it source videos as MKV's. If you include text subtitles
(not image based ones) the parse-subs.sh script can extract those and make them
available in the video player too.

Playback is synced between every viewer using the local system clock, so everyone
can chat about what they're seeing in realtime on voice or text chat, watching
together across any distance.

To encode a film, setup a server, like a simple linode or whatever, and run:

  mkdir -p ./web/public/presentation
  ./encode-presentation.sh ../some/path/to/video.mkv movie-title

a folder web/public/presentation/movie-title will be created and filled with
many small segment files, which are the HLS video stream in various
qualities.

If you wish to extract subtitles, next run

  ./parse-subs.sh ../some/path/to/video.mkv movie-title

this will extract subtitles, converting them to webvtt and creating a subtitle
index file at web/public/presentation/movie-title/subtitles.txt - you can edit
this file to add custom names for your options by following the
filename=lang=Subtitle Name format.

now your presentation is prepared, copy the movienight.html, streamvid.html, and
movienight-assets folder in to web/public/ location, and make that available with
a regular static http server. Any will do, as long as it can serve multiple users
at the same time.

To test your presentation, go to:

  http://yourserver/streamvid.html#movie-title

This player will let you watch the video, skipping around to different parts.

When you're ready to watch it with friends, figure out what the start time would
be in UTC/London time, and go to this url:

  http://yourserver/movienight.html#movie-title/HH.MMZ

Replacing HH and MM with the 24 hour time for the film to start in UTC. You may
need to reload the page after adjusting the values in this URL to see them take
effect. If done correctly, your browser should now display the video's start time
in your local timezone. At this time, the video will automatically begin playing
for everyone who has this webpage open. If anyone joins or reloads the page during
the screening, or has internet trouble, the player will automatically reseek to
the correct location, or make minor timing adjustments by slowing down or speeding
up the playback rate if it is close to correct. By sharing the URL a few hours in
advance, some of your viewers will be able to buffer the video before the start
which may help them have a smooth experience. The minimum internet speed required
to watch is about 80KB/s or 0.6mbit.

The player is known to be compatible with current versions of Safari, Firefox,
Chrome, Microsoft Edge, Steam Big Picture browser, and iOS. It has also been
tested in the PS4 web browser, but it didn't work at all on that platform.

This is just a little project to watch some videos among friends privately, so
I don't intend to develop it much further than my needs, but I would welcome
contributions.

Please note that this system does not include encryption, and is unsuitable
for streaming copyright content where the licensor insists on DRM protection.
I also must stress that you should not share films you do not have the rights to
as that would be illegal in most regions.
