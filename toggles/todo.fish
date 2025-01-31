#!/bin/fish

. (dirname (status filename))/util.fish

spawn-or-move '.class == "Todoist"' todo todoist

hyprctl dispatch togglespecialworkspace todo
