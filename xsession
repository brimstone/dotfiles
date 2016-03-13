keepalive() {
	( while true; do
		"$@" 2>/dev/null >/dev/null
		sleep 1
	done ) &
}
(
sleep 2
xscreensaver -no-splash &

keepalive wicd-client -t
keepalive blueman-applet
#urxvtd -q -f -o
keepalive xcompmgr -n
keepalive parcellite
keepalive $HOME/local/go/bin/ipfs daemon
solaar &
urxvt &
) &
while true; do
	sleep 2m
	bin/us
	xmodmap ~/.Xmodmap
done &
while true; do
	pactl list | grep -q bluetooth-discover || pactl load-module module-bluetooth-discover
	sleep 30
done &
while true; do
	bin/mkbackground.bash
	sleep 10m
done &
xrandr --output LVDS1 --primary
pactl set-sink-mute 0 1

i3
[ $? != 0 ] && urxvt
while [ $(ps ax | grep -v grep | grep -c unison) != 0 ]; do
	notify-send -t 5000 "waiting for unison to finish"
	sleep 5
done
unison loot -batch
[ $(xrandr | grep -c "VGA1 disconnected") ] && xrandr --output VGA1 --off

exit 0
