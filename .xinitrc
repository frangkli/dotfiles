#!bin/zsh

# Configure X11
xsetroot -solid dark
xsetroot -cursor_name left_ptr
xsetroot general
xset fp+ /opt/local/share/fonts/
xset fp rehash
xrdb -merge ~/.Xresources

while true
do
    xsetroot -name "  `$HOME/.local/bin/info/nowmusic` | `$HOME/.local/bin/info/nextask` | `date +'%Y-%m-%d %H:%M'` "
    xset r rate 250 30
    xset b off
    sleep 5
done &

exec /usr/local/bin/dwm
