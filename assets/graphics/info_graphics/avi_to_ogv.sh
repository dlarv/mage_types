#!/bin/bash
ffmpeg -i "$1" -vf "scale=-1:720" -q:v 6 -q:a 6 -g:v 64 "$2"
