#!/bin/fish

set -l src (dirname (status filename))

. $src/../util.fish

test -f "$argv[1]" && set -l img (realpath "$argv[1]") || set -l img $C_STATE/wallpaper/thumbnail.jpg
contains -- "$argv[2]" light dark && set -l theme $argv[2] || set -l theme dark

set -l variants vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content monochrome
set -l hash (sha1sum $img | cut -d ' ' -f 1)

# Cache schemes
mkdir -p $C_CACHE/schemes
set -l dirty_variants
if test -d $C_CACHE/schemes/$hash
    for variant in $variants
        test -f $C_CACHE/schemes/$hash/$variant/$theme.txt || set -a dirty_variants $variant
    end
else
    set dirty_variants $variants
end

if test -n "$dirty_variants"
    # Generate schemes for variants that need it
    set -l colours ($src/score.py $img)
    parallel "mkdir -p $C_CACHE/schemes/$hash/{} && $src/autoadjust.py $theme {} '$colours' | head -c -1 > $C_CACHE/schemes/$hash/{}/$theme.txt" ::: $dirty_variants
end

# Copy schemes from cache
for variant in $variants
    mkdir -p $src/../data/schemes/dynamic/$variant
    cp $C_CACHE/schemes/$hash/$variant/$theme.txt $src/../data/schemes/dynamic/$variant/$theme.txt
end
