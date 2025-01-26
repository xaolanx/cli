#!/bin/fish

set -l chosen_item (cliphist list | fuzzel --dmenu --prompt='Delete from clipboard: ')
test -n "$chosen_item" && echo "$chosen_item" | cliphist delete
