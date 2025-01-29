#!/bin/fish

set script_name (basename (status filename))
set wallpapers_dir (xdg-user-dir PICTURES)/Wallpapers/
set threshold 80

# Max 0 non-option args | h, f and d are exclusive | F and t are also exclusive
argparse -n 'caelestia-wallpaper' -X 0 -x 'h,f,d' -x 'F,t' \
    'h/help' \
    'f/file=' \
    'd/directory=' \
    'F/no-filter' \
    't/threshold=!_validate_int --min 0' \
    -- $argv
or exit

. (dirname (status filename))/util.fish

if set -q _flag_h
    echo 'Usage:'
    echo '    caelestia wallpaper'
    echo '    caelestia wallpaper [ -h | --help ]'
    echo '    caelestia wallpaper [ -f | --file ]'
    echo '    caelestia wallpaper [ -d | --directory ] [ -F | --no-filter ]'
    echo '    caelestia wallpaper [ -d | --directory ] [ -t | --threshold ]'
    echo
    echo 'Options:'
    echo '    -h, --help                    Print this help message and exit'
    echo '    -f, --file <file>             The file to change wallpaper to'
    echo '    -d, --directory <directory>   The folder to select a random wallpaper from (default '$wallpapers_dir')'
    echo '    -F, --no-filter               Do not filter by size'
    echo '    -t, --threshold <threshold>   The minimum percentage of the size the image must be greater than to be selected (default '$threshold')'
else
    set cache_dir $CACHE/wallpaper

    # The path to the last chosen wallpaper
    set last_wallpaper_path "$cache_dir/last.txt"

    # Use wallpaper given as argument else choose random
    if set -q _flag_f
        set chosen_wallpaper (realpath $_flag_f)

        if ! test -f $chosen_wallpaper
            echo "$chosen_wallpaper does not exist"
            exit 1
        end

        # Set last wallpaper if not same as given
        if [ -f "$last_wallpaper_path" ]
            set last_wallpaper (cat $last_wallpaper_path)
            [ -z "$last_wallpaper" -o "$last_wallpaper" = "$chosen_wallpaper" ] && set -e last_wallpaper
        end
    else
        # The path to the directory containing the selection of wallpapers
        set -q _flag_d && set wallpapers_dir (realpath $_flag_d)

        if ! test -d $wallpapers_dir
            echo "$wallpapers_dir does not exist"
            exit 1
        end

        # Get all files in $wallpapers_dir and exclude the last wallpaper (if it exists)
        if [ -f "$last_wallpaper_path" ]
            set last_wallpaper (cat $last_wallpaper_path)
            [ -n "$last_wallpaper" ] && set unfiltered_wallpapers (find $wallpapers_dir -type f | grep -v $last_wallpaper)
        end
        set -q unfiltered_wallpapers || set unfiltered_wallpapers (find $wallpapers_dir -type f)

        # Filter by resolution if no filter option is not given
        if set -q _flag_F
            set wallpapers $unfiltered_wallpapers
        else
            set -l screen_size (hyprctl monitors -j | jq -r 'max_by(.width * .height) | "\(.width)\n\(.height)"')
            set -l wall_sizes (identify -ping -format '%w %h\n' $unfiltered_wallpapers)

            # Apply threshold
            set -q _flag_t && set threshold $_flag_t
            set screen_size[1] (math $screen_size[1] x $threshold / 100)
            set screen_size[2] (math $screen_size[2] x $threshold / 100)

            # Add wallpapers that are larger than the screen size * threshold to list to choose from ($wallpapers)
            for i in (seq 1 (count $wall_sizes))
                set -l wall_size (string split ' ' $wall_sizes[$i])
                if [ $wall_size[1] -ge $screen_size[1] -a $wall_size[2] -ge $screen_size[2] ]
                    set -a wallpapers $unfiltered_wallpapers[$i]
                end
            end
        end

        # Check if the $wallpapers list is unset or empty
        if ! set -q wallpapers || [ -z "$wallpapers" ]
            echo "No eligible files found in $wallpapers_dir"
            exit 1
        end

        # Choose a random wallpaper from the $wallpapers list
        set chosen_wallpaper (random choice $wallpapers)
    end

    # Change the wallpaper and output change if success
    hyprctl hyprpaper preload $chosen_wallpaper > /dev/null
    for monitor in (hyprctl -j monitors | jq -r '.[].name')
        hyprctl hyprpaper wallpaper "$monitor,$chosen_wallpaper" > /dev/null && log "Changed wallpaper on $monitor to $chosen_wallpaper"
    end

    # Unload unused wallpapers to preserve memory
    hyprctl hyprpaper unload unused > /dev/null

    # Generate colour scheme for wallpaper
    set -l src (dirname (status filename))
    $src/scheme/apply-scheme.fish $chosen_wallpaper

    # Store the wallpaper chosen
    mkdir -p $cache_dir
    echo $chosen_wallpaper > $last_wallpaper_path
    ln -sf $chosen_wallpaper "$cache_dir/current"
    magick $chosen_wallpaper -fill black -colorize 10% -blur 0x10 "$cache_dir/blur" &
end
