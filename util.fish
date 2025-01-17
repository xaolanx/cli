function log -a text
    set_color cyan
    # Pass arguments other than text to echo
    echo $argv[2..] -- ":: $text"
    set_color normal
end

function warn -a text
    set_color yellow
    # Pass arguments other than text to echo
    echo $argv[2..] -- ":: $text"
    set_color normal
end

function error -a text
    set_color red
    # Pass arguments other than text to echo
    echo $argv[2..] -- ":: $text"
    set_color normal
end
