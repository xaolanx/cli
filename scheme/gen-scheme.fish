#!/bin/fish

set -l src (dirname (status filename))

. $src/../util.fish

test -f "$argv[1]" && set -l img "$argv[1]" || set -l img $C_STATE/wallpaper/current
set -l img (realpath $img)
contains -- "$argv[2]" light dark && set -l theme $argv[2] || set -l theme dark
test -n "$argv[3]" && set -l scheme $argv[3] || set -l scheme (cat $C_STATE/scheme/dynamic-scheme.txt 2> /dev/null || echo 'vibrant')

# Generate colours
if test $scheme = 'monochrome'
    $src/autoadjust.py $theme $scheme (okolors $img -k 14)
else
    test $theme = light && set -l lightness 50 || set -l lightness 70
    $src/autoadjust.py $theme $scheme (okolors $img -k 14 -w 0 -l $lightness)
end

# Generate layers and accents
$src/genmaterial.py $img $theme $scheme | head -c -1  # Trim trailing newline
