#!/bin/sh
echo -ne '\033c\033]0;Mage-Types\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Mage-Types_v0-0-5.x86_64" "$@"
