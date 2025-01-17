#!/bin/fish

. (dirname (status filename))/util.fish

mkdir -p "$CACHE/screenshots"
set tmp_file "$CACHE/screenshots/$(date +'%Y%m%d%H%M%S')"
grim $argv $tmp_file; and wl-copy < $tmp_file; or exit 1

set action (notify-send -i 'image-x-generic-symbolic' -h "STRING:image-path:$tmp_file" \
    -a (basename (status current-filename)) --action='open=Open' --action='save=Save' \
        'Screenshot taken' "Screenshot stored in $tmp_file and copied to clipboard")
switch $action
    case 'open'
        uwsm app -- swappy -f $tmp_file & disown
    case 'save'
        set save_file (uwsm app -- zenity --file-selection --save --title='Save As')
        [ -z $save_file ] && exit 0
        if [ -f $save_file ]
            uwsm app -- yad --image='abrt' --title='Warning!' --text-align='center' --buttons-layout='center' --borders=20 \
                --text='<span size="x-large">Are you sure you want to overwrite this file?</span>' || exit 0
        end
        cp -f $tmp_file $save_file
end
