function move-client -a selector -a workspace
    if hyprctl -j clients | jq -e 'first(.[] | select('$selector')).workspace.name != "special:'$workspace'"' > /dev/null
        # Window not in correct workspace
        set -l window_addr (hyprctl -j clients | jq -r 'first(.[] | select('$selector')).address')
        hyprctl dispatch movetoworkspacesilent "special:$workspace,address:$window_addr"
    end
end

function spawn-client -a selector
    # Spawn if doesn't exist
    hyprctl -j clients | jq -e "first(.[] | select($selector))" > /dev/null
    set -l stat $status
    if test $stat != 0
        uwsm app -- $argv[2..] & disown
    end
    test $stat != 0  # Exit 1 if already exists
end

function spawn-or-move -a selector -a workspace
    spawn-client $selector $argv[3..] || move-client $selector $workspace
end
