#!/bin/fish

set chosen_item (cliphist list | fuzzel --dmenu --prompt='Delete from clipboard: ')
test -n "$chosen_item" && echo "$chosen_item" | cliphist delete
