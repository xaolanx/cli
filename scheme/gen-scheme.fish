#!/bin/fish

set -l src (dirname (status filename))

. $src/../util.fish

test -f "$argv[1]" && set -l img (realpath "$argv[1]") || set -l img $C_STATE/wallpaper/thumbnail.jpg
contains -- "$argv[2]" light dark && set -l theme $argv[2] || set -l theme dark

set -l variants vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content

# Generate colours
test $theme = light && set -l lightness 50 || set -l lightness 70
set -l colours (okolors $img -k 14 -w 0 -l $lightness)
for variant in $variants
    mkdir -p $src/../data/schemes/dynamic/$variant
    $src/autoadjust.py $theme $variant $colours > $src/../data/schemes/dynamic/$variant/$theme.txt
end
mkdir -p $src/../data/schemes/dynamic/monochrome
$src/autoadjust.py $theme monochrome (okolors $img -k 14) > $src/../data/schemes/dynamic/monochrome/$theme.txt

set -la variants monochrome

# Generate layers and accents
set -l tmp (mktemp)
$src/genmaterial.py $img $theme > $tmp
for variant in $variants
    grep -FA 15 $variant $tmp | tail -15 | head -c -1 >> $src/../data/schemes/dynamic/$variant/$theme.txt
end
rm $tmp
