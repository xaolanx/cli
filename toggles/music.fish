#!/bin/fish

. (dirname (status filename))/util.fish

move-client '.class == "feishin"' music
move-client '.class == "Spotify" or .initialTitle == "Spotify" or .initialTitle == "Spotify Free"' music

hyprctl dispatch togglespecialworkspace music
