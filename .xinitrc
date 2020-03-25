#!bin/zsh

# Configure X11
xsetroot -solid dark
xsetroot -cursor_name left_ptr
xset fp+ /opt/local/share/fonts/
xset fp rehash
xrdb -merge ~/.Xresources
xset r rate 250 30
xset b off

while true
do
    xsetroot -name "  `$HOME/.local/bin/info/nowmusic` | `$HOME/.local/bin/info/nextask` | `date +'%Y-%m-%d %H:%M'` | `$HOME/.local/bin/info/battery` "
    sleep 3
done &

exec /usr/local/bin/dwm
