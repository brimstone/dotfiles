(
sleep 2
xscreensaver -no-splash &
wicd-client -t &
blueman-applet &
urxvtd -q -f -o
solaar &
xmodmap ~/.Xmodmap
xcompmgr -n 2>/dev/null &
#~/bin/notify-client >/dev/null &
parcellite &
urxvtc &
) &
while true; do
	sleep 2m
	pactl list | grep -q bluetooth-discover || pactl load-module module-bluetooth-discover
	bin/us
done &
while true; do
	programming/bash/mkbackground.bash
	sleep 10m
done &
i3
[ $? != 0 ] && urxvt
while [ $(ps ax | grep -v grep | grep -c unison) != 0 ]; do
	notify-send -t 5000 "waiting for unison to finish"
	sleep 5
done
unison loot -batch
[ $(xrandr | grep -c "VGA1 disconnected") ] && xrandr --output VGA1 --off

exit 0
