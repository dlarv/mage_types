#!/bin/bash

infile=$1
name="$(basename $1)"
name="${name%.*}"
path="$(dirname $1)"

mv ~/downloads/audiomass-output.mp3 "$infile"
ffmpeg -y -i "$infile" -vn -acodec libvorbis "$path/$name.ogg"
