#!/bin/fish

. (dirname (status filename))/util.fish

spawn-or-move '.class == "vesktop"' communication vesktop --enable-features=WebRTCPipeWireCapturer

# Has whatsapp firefox profile
if grep -q 'Name=whatsapp' ~/.mozilla/firefox/profiles.ini
    spawn-or-move '.class == "whatsapp"' communication firefox --name whatsapp -P whatsapp 'https://web.whatsapp.com'
end

hyprctl dispatch togglespecialworkspace communication
