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

is_running() {
	ps_out=`ps -ef | grep "$1" | grep -v 'grep' | grep -v $0`
	result=$(echo $ps_out | grep "$1")	
	if [[ "$result" != "" ]];then		
	    return 0
	else
	    return 1
	fi
}

if [ systemd-detect-virt = "oracle" ]; then
	/usr/bin/VBoxClient-all
fi

RESULT=$(sh $HOME/.checksession)

if [[ "$RESULT" != "" ]]; then
	xrandr --output DisplayPort-0 --auto --output HDMI-A-0 --primary --left-of DisplayPort-0 &
	xrdb -merge /home/pheonix/.Xresources &
	sh /home/pheonix/.checkfeh &	
	( ! is_running 'compton' ) && compton -b --config "$HOME/.compton.conf" &
	
	/home/pheonix/.bin/lemon &
	
	( ! is_running "polkit-gnome-authentication-agent-1" ) && /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
	( ! is_running "dunst" ) && dunst -config "$HOME/.config/dunst/dunstrc" &
	( ! is_running "mpd" ) && mpd &
	( ! is_running "redshift" ) && redshift &
	start-pulseaudio-x11 &
	#( ! is_running "insync" ) && insync start &
	#( ! is_running "nextcloud" ) && nextcloud &
	( ! is_running "syncthing" ) && syncthing -no-browser &
	( ! is_running "xfce4-power-manager" ) && xfce4-power-manager &
	wal -R &
fi
