#!/bin/bash
ffmpeg -i "$1" -q:v 6 -q:a 6 -g:v 64 "$2"
