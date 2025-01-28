#!/bin/fish

function gen-hypr
    for colour in $argv
        set -l split (string split ' ' $colour)
        echo "\$$split[1] = $split[2]"
    end
end

function gen-scss
    for colour in $argv
        set -l split (string split ' ' $colour)
        echo "\$$split[1]: #$split[2];"
    end
end

function gen-scss-palette
    echo '$palette: ('
    for colour in $argv
        set -l split (string split ' ' $colour)
        echo "    \"$split[1]\": #$split[2],"
    end
    echo ');'
end

function gen-ini -a program
    cp (dirname (status filename))/../data/$program.template $CONFIG/../$program/schemes/dynamic.ini
    for colour in $argv[2..]
        set -l split (string split ' ' $colour)
        sed -i "s/\$$split[1]/$split[2]/g" $CONFIG/../$program/schemes/dynamic.ini
    end
end

function gen-gtk
    cp (dirname (status filename))/../data/gtk.template $CONFIG/gtk/schemes/dynamic.css
    for colour in $argv
        set -l split (string split ' ' $colour)
        sed -i "s/\$$split[1]/#$split[2]/g" $CONFIG/gtk/schemes/dynamic.css
    end
end

. (dirname (status filename))/../util.fish

set -l src (dirname (status filename))
set -l colours ($src/gen-scheme.fish $argv[1])

if test -d $CONFIG/../hypr/scheme
    log 'Generating hypr scheme'
    gen-hypr $colours > $CONFIG/../hypr/scheme/dynamic.conf
end

if test -d $CONFIG/shell
    log 'Generating shell scheme'
    gen-scss $colours > $CONFIG/shell/scss/scheme/_dynamic.scss
end

if test -d $CONFIG/safeeyes
    log 'Generating SafeEyes scheme'
    gen-scss $colours > $CONFIG/safeeyes/scheme/_dynamic.scss
end

if test -d $CONFIG/discord
    log 'Generating discord scheme'
    gen-scss $colours > $CONFIG/discord/dynamic/_variables.scss
    gen-scss-palette $colours >> $CONFIG/discord/dynamic/_variables.scss
    sass -q --no-charset --no-source-map $CONFIG/discord/dynamic/dynamic.scss $CONFIG/discord/themes/dynamic.theme.css
end

if test -d $CONFIG/../foot/schemes
    log 'Generating foot scheme'
    gen-ini foot $colours
end

if test -d $CONFIG/../fuzzel/schemes
    log 'Generating fuzzel scheme'
    gen-ini fuzzel $colours
end

if test -d $CONFIG/gtk
    log 'Generating GTK+ schemes'
    gen-gtk $colours
    $CONFIG/gtk/update-scheme.fish
end

# Reload programs if dynamic scheme
if test -f $CACHE/scheme/current.txt -a "$(cat $CACHE/scheme/current.txt)" = 'dynamic'
    caelestia scheme dynamic
end
