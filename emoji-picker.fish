#!/bin/fish

set -l chosen_item (cat (dirname (status filename))/data/emojis.txt | fuzzel --dmenu)
test -n "$chosen_item" && echo "$chosen_item" | cut -d ' ' -f 1 | tr -d '\n' | wl-copy
