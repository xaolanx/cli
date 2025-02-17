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

function gen-ini -a program
    cp (dirname (status filename))/../data/$program.template $CONFIG/../$program/schemes/dynamic.ini
    for colour in $argv[2..]
        set -l split (string split ' ' $colour)
        sed -i "s/\$$split[1]/$split[2]/g" $CONFIG/../$program/schemes/dynamic.ini
    end
end

function gen-json
    set -e jq_args
    for colour in $argv
        set -l split (string split ' ' $colour)
        set -a jq_args --arg $split[1] "#$split[2]"
    end
    jq -n $jq_args '$ARGS.named'
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
    gen-scss $colours > /tmp/_colours.scss
    sass --no-charset --no-source-map -I /tmp $src/../data/discord.template $CONFIG/discord/themes/dynamic.theme.css
end

if test -d $CONFIG/../foot/schemes
    log 'Generating foot scheme'
    gen-ini foot $colours
end

if test -d $CONFIG/../fuzzel/schemes
    log 'Generating fuzzel scheme'
    gen-ini fuzzel $colours
end

if test -d $CONFIG/vscode
    log 'Generating VSCode scheme'
    gen-json $colours > $CONFIG/vscode/schemes/dynamic.json
end

if test -d $CONFIG/gtk
    log 'Generating GTK+ schemes'
    gen-gtk $colours
end

# Reload programs if dynamic scheme
if test -f $CACHE/scheme/current.txt -a "$(cat $CACHE/scheme/current.txt)" = 'dynamic'
    caelestia scheme dynamic
end
