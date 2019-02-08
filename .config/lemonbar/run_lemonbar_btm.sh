#!/usr/bin/env bash

. $(dirname $0)/config


if [ -e "${PANEL_FIFO_BTM}" ]; then 
    rm "${PANEL_FIFO_BTM}"
fi
mkfifo "${PANEL_FIFO_BTM}"

xprop -spy -root _NET_ACTIVE_WINDOW | sed -un 's/.*\(0x.*\)/WIN\1/p' > "${PANEL_FIFO_BTM}" &

get_ip(){
	
	ip=$(curl -s 'http://api.ipify.org')

	if [ -d "/proc/sys/net/ipv4/conf/tun0" ]; then
        state=1
    elif [ -d "/proc/sys/net/ipv4/conf/ppp0" ]; then
        state=1
    else
        state=0
    fi

    while true; do
    	
        if [ -d "/proc/sys/net/ipv4/conf/tun0" ]; then
        	state2=1
        	if (( $state != $state2 )); then
        		state=1
        		ip=$(curl -s 'http://api.ipify.org')
        	fi
            vpn="%{F${color_vol_warn} T3}${sep_left}%{F${color_back} B${color_vol_warn}} %{T2}${icon_vpn_on} %{T1}${ip} %{F${color_vol_warn} T3}${sep_left}%{F- B- T1}"
        elif [ -d "/proc/sys/net/ipv4/conf/ppp0" ]; then
        	if (( $state != $state2 )); then
        		state=1
        		ip=$(curl -s 'http://api.ipify.org')
        	fi
            vpn="%{F${color_vol_warn} T3}${sep_left}%{F${color_back} B${color_vol_warn}} %{T2}${icon_vpn_on} %{T1}${ip} %{F${color_vol_warn} T3}${sep_left}%{F- B- T1}"
        else
        	state2=0
            vpn="%{F${color_sec_b1} T3}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_vpn_off}%{F- T1} Hidden %{F${color_sec_b1} T3}${sep_left}%{F- B- T1}"
        fi
        echo "IP ${vpn}"

        sleep ${IP_SLEEP}
    done
}

get_ip > "${PANEL_FIFO_BTM}" &

while read -r line; do
    case $line in
        IP*)
            fn_ip="${line#IP }"
            ;;
        WIN*)            
            num_title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2 | wc -c)

            if (( num_title > 30 )); then
                name="$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2 | head -1 | head -c 30)..."
            else
                name="$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)"
            fi
            title="%{F${color_sec_b2} B${color_sec_b2} T3}${sep_right}%{F- B${color_sec_b2} T1} ${name} %{F${color_sec_b2} B- T3}${sep_right}%{F- B- T1} "
            ;;
    esac    
    printf "%s\n" "%{l}${title} %{c} %{r}${fn_ip}"
done < "${PANEL_FIFO_BTM}" | lemonbar -d -f "${FONTS}" -f "${ICONFONTS}" -f "${FONTS_P}" -g "${GEOMETRY2}" -B "${BBG}" -F "${BFG}" -o "${FOFF}" | sh > /dev/null