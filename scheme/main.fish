#!/bin/fish

# Usage:
#   caelestia scheme <scheme> <flavour> [mode]
#   caelestia scheme <scheme> [flavour]
#   caelestia scheme [scheme]

function set-scheme -a path name mode
    mkdir -p $C_STATE/scheme

    # Update scheme colours
    cp $path $C_STATE/scheme/current.txt

    # Update scheme name
    echo -n $name > $C_STATE/scheme/current-name.txt

    # Update scheme mode
    echo -n $mode > $C_STATE/scheme/current-mode.txt

    log "Changed scheme to $name ($mode)"
end

set -l src (dirname (status filename))/..
set -l schemes $src/data/schemes

. $src/util.fish

set -l valid_schemes (basename -a $schemes/*)

test -z "$argv" && set -l argv[1] (random choice $valid_schemes)

if contains -- "$argv[1]" $valid_schemes
    set -l flavours (basename -a (find $schemes/$argv[1]/ -mindepth 1 -maxdepth 1 -type d) 2> /dev/null)
    set -l modes (basename -s .txt (find $schemes/$argv[1]/ -mindepth 1 -maxdepth 1 -type f) 2> /dev/null)

    if test -n "$modes"
        # Scheme only has one flavour, so second arg is mode
        if test -z "$argv[2]"
            # Try to use current mode if not provided and current mode exists for flavour, otherwise random mode
            set argv[2] (cat $C_STATE/scheme/current-mode.txt 2> /dev/null)
            contains -- "$argv[2]" $modes || set argv[2] (random choice $modes)
        end

        if contains -- "$argv[2]" $modes
            # Provided valid mode
            set-scheme $schemes/$argv[1]/$argv[2].txt $argv[1] $argv[2]
        else
            error "Invalid mode for $argv[1]: $argv[2]"
        end
    else
        # Scheme has multiple flavours, so second arg is flavour
        test -z "$argv[2]" && set -l argv[2] (random choice $flavours)

        if contains -- "$argv[2]" $flavours
            # Provided valid flavour
            set -l modes (basename -s .txt $schemes/$argv[1]/$argv[2]/*.txt)
            if test -z "$argv[3]"
                # Try to use current mode if not provided and current mode exists for flavour, otherwise random mode
                set argv[3] (cat $C_STATE/scheme/current-mode.txt 2> /dev/null)
                contains -- "$argv[3]" $modes || set argv[3] (random choice $modes)
            end

            if contains -- "$argv[3]" $modes
                # Provided valid mode
                set-scheme $schemes/$argv[1]/$argv[2]/$argv[3].txt $argv[1]-$argv[2] $argv[3]
            else
                error "Invalid mode for $argv[1] $argv[2]: $argv[3]"
            end
        else
            # Invalid flavour
            error "Invalid flavour for $argv[1]: $argv[2]"
        end
    end
else
    error "Invalid scheme: $argv[1]"
end
