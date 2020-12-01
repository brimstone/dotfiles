keepalive() {
	( while true; do
		"$@" 2>/dev/null >/dev/null
		sleep 1
	done ) &
}

export PATH=$PATH:$HOME/bin
(
sleep 10
xscreensaver -no-splash &

keepalive wicd-client -t
keepalive blueman-applet
#urxvtd -q -f -o
#keepalive xcompmgr -n
keepalive parcellite
keepalive ~/bin/dashboard-agent
keepalive afuse -f -o timeout=300 -o mount_template='sshfs -o reconnect %r:/ %m' -o unmount_template='fusermount -u -z %m' ~/mnt/sshfs
keepalive afuse -f -o timeout=300 -o mount_template='bash -c "rclone mount --vfs-cache-mode full --no-modtime --vfs-cache-max-age 1m --daemon %r: %m; sleep 1"' -o unmount_template='fusermount -u -z %m' ~/mnt/rclone
keepalive ibus-daemon
keepalive nm-applet
xcape
) &
while true; do
	xmodmap ~/.Xmodmap
	sleep 2m
	[ ! -x bin/us ] || bin/us >/dev/null 2>&1
done &
while true; do
	bin/mkbackground.bash
	sleep 10m
done &
xrandr --output LVDS1 --primary
pactl set-sink-mute 0 1

export QT_AUTO_SCREEN_SCALE_FACTOR=0
autorandr --change

i3
[ $? != 0 ] && urxvt
while [ $(ps ax | grep -v grep | grep -c unison) != 0 ]; do
	notify-send -t 5000 "waiting for unison to finish"
	sleep 5
done
unison loot -batch
[ $(xrandr | grep -c "VGA1 disconnected") ] && xrandr --output VGA1 --off

exit 0
