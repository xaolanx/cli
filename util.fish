function _out -a colour -a level -a text
    set_color $colour
    # Pass arguments other than text to echo
    echo $argv[4..] -- ":: [$level] $text"
    set_color normal
end

function log -a text
    _out cyan LOG $text $argv[2..]
end

function warn -a text
    _out yellow WARN $text $argv[2..]
end

function error -a text
    _out red ERROR $text $argv[2..]
end

set -q XDG_CACHE_HOME && set CACHE $XDG_CACHE_HOME/caelestia || set CACHE $HOME/.cache/caelestia
