#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi

if [ systemd-detect-virt = "oracle" ]; then
	/usr/bin/VBoxClient-all
fi

#SERVICE="2bwm"
#ps_out=`ps -ef | grep ${SERVICE} | grep -v 'grep' | grep -v $0`
#RESULT=$(echo $ps_out | grep ${SERVICE})
RESULT=$(sh /home/pheonix/.checksession)

if [[ "$RESULT" != "" ]];then
	xrandr --output DisplayPort-0 --auto --output HDMI-A-0 --primary --left-of DisplayPort-0 &
	xrdb -merge /home/pheonix/.Xresources &
	sh /home/pheonix/.checkfeh &
	compton -b --config "/home/pheonix/.compton.conf" &
	sh /home/pheonix/.bin/pbar 2 &
	/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
	dunst -config "/home/pheonix/.config/dunst/dunstrc" &
	mpd &
	redshift &
	start-pulseaudio-x11 &
	nextcloud &
	syncthing -no-browser &
	xfce4-power-manager &
	#urxvt -title scratch &
fi
