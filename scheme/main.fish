#!/bin/fish

set -l src (dirname (status filename))/..

. $src/util.fish

set -l valid_schemes (path change-extension '' $src/data/schemes/* | sed 's!.*/!!')
set -l light_schemes latte

if contains -- "$argv[1]" $valid_schemes
    mkdir -p $C_STATE/scheme

    # Update scheme colours
    cp $src/data/schemes/$argv[1].txt $C_STATE/scheme/current.txt

    # Update scheme name
    echo -n $argv[1] > $C_STATE/scheme/current-name.txt

    # Update scheme mode
    if test $argv[1] = dynamic
        set colour_scheme (cat $C_STATE/scheme/dynamic-mode.txt)
    else
        contains -- "$argv[1]" $light_schemes && set colour_scheme light || set colour_scheme dark
    end
    echo -n $colour_scheme > $C_STATE/scheme/current-mode.txt

    log "Changed scheme to $argv[1]"
else
    error "Invalid scheme: $argv[1]"
end
