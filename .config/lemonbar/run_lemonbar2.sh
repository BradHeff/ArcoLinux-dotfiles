#!/usr/bin/env bash

. $(dirname $0)/config


if [ -e "${PANEL_FIFO}" ]; then 
    rm "${PANEL_FIFO}"
fi
mkfifo "${PANEL_FIFO}"

#conky -c $(dirname $0)/lemonbar_conky > "${PANEL_FIFO}" &

xprop -spy -root _NET_ACTIVE_WINDOW | sed -un 's/.*\(0x.*\)/WIN\1/p' > "${PANEL_FIFO}" &

perl "$HOME/.config/lemonbar/i3_workspaces.pl" > "${PANEL_FIFO}" &

space() {
    while true; do
        spce=$(df -h | grep '/sdb2' | awk '{print $4}')
        spce="${spce%?}"

        echo "SPACE %{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_space}%{F- T1} ${spce} GB"

        sleep ${SPACE_SLEEP}
    done
}
space > "${PANEL_FIFO}" &

music() {
    while true; do
        NCMP=$(mpc | grep "^\[playing\]" | awk '{print $1}')
        NUM_NCMP=$(mpc | head -1 | wc -c )
        S_NCMP=$(mpc | head -1 | head -c 30)

        pause='Pause'
        str=""

        if [ "$NCMP" = "[playing]" ]; then        
            if [ "$NUM_NCMP" -lt 30 ]; then            
                str=$(mpc current)            
            else
                str="${S_NCMP}..."
            fi
        else
            str="${pause}"
        fi

        echo "MUSIC %{F${color_sec_b2}}${sep_left}%{B${color_sec_b2}}%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_music}%{F- T1} ${str}"
        
        sleep ${MUSIC_SLEEP}
    done
}
music > "${PANEL_FIFO}" &

cnt=0
get_updates(){
    while true; do
        if (( ${cnt} == 300 )); then
            sudo pacman -Syy            
            cnt=0
        else
            cnt=$((cnt + 1))
        fi
        
        P_updates=`pacman -Qu | wc -l`
        Y_updates=`yay -Qu | wc -l`
        

        if (( "${P_updates}" > 0 )); then
            echo "UPDATE %{F${color_pacman} B${color_sec_b2}}${sep_left}%{F${color_back} B${color_pacman} T2} ${icon_pacman} %{T1}${P_updates} %{F${color_sec_b2} B${color_pacman}}${sep_left}%{F- B${color_sec_b2} T1}"
        else
            if (( "${Y_updates}" > 0 )); then
                echo "UPDATE %{F${color_yay} B${color_sec_b2}}${sep_left}%{F${color_back} B${color_yay} T2} ${icon_update} %{T1}${Y_updates} %{F${color_sec_b2} B${color_yay}}${sep_left}%{F- B${color_sec_b2} T1}"
            else
                echo "UPDATE %{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2} T1} ${icon_update}%{F- T2} %{T1}${P_updates} %{F${color_sec_b2} B${color_sec_b2}}${sep_left}%{F- B${color_sec_b2} T1}"
            fi
        fi
        sleep ${UPDATE_SLEEP}
    done
}

get_updates > "${PANEL_FIFO}" &

get_vpn(){
    while true; do
        if [ -d "/proc/sys/net/ipv4/conf/tun0" ]; then
            vpn="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} %{T2}${icon_vpn_on} %{T1}On %{F${color_sec_b2} B${color_head}}${sep_left}%{F- B${color_sec_b2} T1}"
        elif [ -d "/proc/sys/net/ipv4/conf/ppp0" ]; then
            vpn="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} %{T2}${icon_vpn_on} %{T1}On %{F${color_sec_b2} B${color_head}}${sep_left}%{F- B${color_sec_b2} T1}"
        else
            vpn="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vpn_off}%{F- T1} Off "
        fi  
        echo "VPN ${vpn}"

        sleep ${VPN_SLEEP}
    done
}

get_vpn > "${PANEL_FIFO}" &

clock() 
{
    while true; do        
        local time="$(date +'%_I:%M%P')"
        # time
        echo "CLOCK %{F${color_cpu}}${sep_left}%{F${color_back} B${color_cpu}} %{T2}${icon_clock} %{T1}${time} %{F- B- T1}"
        sleep ${TIME_SLEEP}
    done
}

clock > "${PANEL_FIFO}" &

datez() 
{
    while true; do
        local dates="$(date +'%a %d %b')"        
        echo "DATE %{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_date} %{F- T1}${dates}%{F- B- T1}"
        sleep ${DATE_SLEEP}
    done
}

datez > "${PANEL_FIFO}" &

volume()
{
    cnt_vol=${upd_vol}

    while true; do
        local vol="$(amixer get Master | grep -E -o '[0-9]{1,3}?%' | head -1 | cut -d '%' -f1)"
        local mut="$(amixer get Master | grep -E -o 'off' | head -1)"

        if [[ ${mut} == "off" ]]; then
            echo "VOLUME %{F${color_yay}}${sep_left}%{F${color_back} B${color_yay}} %{T2}${icon_vol_mute} %{T1}MUTE %{F${color_sec_b1} B${color_yay}}${sep_left}%{F- B- T1} "
        elif (( vol == 0 )); then
            echo "VOLUME %{F${color_yay}}${sep_left}%{F${color_back} B${color_yay}} %{T2}${icon_vol_mute} %{T1}${vol}% %{F${color_sec_b1} B${color_yay}}${sep_left}%{F- B- T1} "
        elif (( vol > 70 )); then
            echo "VOLUME %{F${color_vol_alert}}${sep_left}%{F${color_back} B${color_vol_alert}} %{T2}${icon_vol} %{T1}${vol}% %{F${color_sec_b1} B${color_vol_alert}}${sep_left}%{F- B- T1} "
        elif (( vol > 55 )); then
            echo "VOLUME %{F${color_vol_warn}}${sep_left}%{F${color_back} B${color_vol_warn}} %{T2}${icon_vol} %{T1}${vol}% %{F${color_sec_b1} B${color_vol_warn}}${sep_left}%{F- B- T1} "
        elif (( vol > 10 )); then
            echo "VOLUME %{F${color_vol_good}}${sep_left}%{F${color_back} B${color_vol_good}} %{T2}${icon_vol} %{T1}${vol}% %{F${color_sec_b1} B${color_vol_good}}${sep_left}%{F- B- T1} "
        else
            echo "VOLUME %{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} ${vol}% %{F${color_sec_b1} B${color_sec_b2} T1}${sep_left}%{F- B- T1} "
        fi

        sleep ${VOLUME_SLEEP} 
    done
}

volume > "${PANEL_FIFO}" &

weather(){
    while true; do
        temp=$(perl $HOME/.config/lemonbar/weather.pl)
        
        temp="${temp}%{F${color_sec_b2} B${color_sec_b2}}${sep_left}%{F- B${color_sec_b2} T1}"
        
        echo "WEATHER ${temp}"

        sleep ${WEATHER_SLEEP}
    done

}

weather > "${PANEL_FIFO}" &

get_load(){
    while true; do
        load=$(uptime | awk '{print $(NF-2)}')
        load="${load//,}"

        if (( $(echo "$load < 2.8" | bc -l) ));
        then
            usage="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_load}%{F- T1} ${load} %{F${color_sec_b2} B${color_sec_b2}}${sep_left}"
        elif (( $(echo "$load < 4.8" | bc -l) ));
        then
            usage="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} %{T2}${icon_load} %{T1}${load} %{F${color_sec_b2} B${color_head}}${sep_left}"        
        else
            usage="%{F${color_pacman}}${sep_left}%{F${color_back} B${color_pacman}} %{T2}${icon_load} %{T1}${load} %{F${color_sec_b2} B${color_pacman}}${sep_left}"        
        fi
        echo "LOAD ${usage}%{F- B${color_sec_b2} T1}"

        sleep ${LOAD_SLEEP}
    done

}

#get_load > "${PANEL_FIFO}" &

get_insync(){
    while true; do
        command=$(insync get_status)

        if [[ "${command}" == "SYNCED" ]]; then
            status="%{F${color_cpu}}${sep_left}%{F${color_back} B${color_cpu}} %{T2}${icon_synced} %{F- T1}%{F${color_sec_b2} B${color_cpu}}${sep_left}%{F- B${color_sec_b2} T1}"
        elif [[ "${command}" == "SYNCING" ]]; then
            status="%{F${color_sunset}}${sep_left}%{F${color_back} B${color_sunset}} %{T2}${icon_syncing} %{F- T1}%{F${color_sec_b2} B${color_sunset}}${sep_left}%{F- B${color_sec_b2} T1}"
        else
            status="%{F${color_vol_alert}}${sep_left}%{F${color_back} B${color_vol_alert}} %{T2}${icon_sync_error} %{F- T1}%{F${color_sec_b2} B${color_vol_alert}}${sep_left}%{F- B${color_sec_b2} T1}"
        fi

        echo "SYNC ${status}"

        sleep ${SYNC_SLEEP}
    done
}

get_insync > "${PANEL_FIFO}" &

while read -r line; do
    case $line in
        SYNC*)
            fn_sync="${line#SYNC }"
            ;;
        CLOCK*)
            fn_time="${line#CLOCK }"
            ;;
        DATE*)
            fn_date="${line#DATE }"
            ;;
        VOLUME*)
            fn_vol="${line#VOLUME }"
            ;; 
        WSP*)
            # I3 Workspaces
            wsp="%{F${color_back} B${color_wsp} T1} " #%{F${color_back} B${color_head}} %{T2}${icon_wsp}%{T1}"
            set -- ${line#???}
            while [ $# -gt 0 ] ; do
                case $1 in
                FOC*)
                    wsp="${wsp}%{F${color_wsp} B${color_head}}${sep_right}%{F${color_back} B${color_head} T1} ${1#???} %{F${color_head} B${color_wsp}}${sep_right}"
                    #wsp="${wsp}%{F${color_head} B${color_wsp}}${sep_right}%{F${color_back} B${color_wsp} T1} ${1#???} %{F${color_wsp} B${color_head}}${sep_right}"
                    ;;
                INA*|URG*|ACT*)
                    wsp="${wsp}%{F${color_disable} T1} ${1#???} "
                    ;;
                esac
                shift
            done
            fn_work="${wsp} %{F${color_wsp} B${color_sec_b2}}${sep_right}"
            ;;       
        MUSIC*)
            fn_music="${line#MUSIC }"
            ;;
        UPDATE*)
            fn_update="${line#UPDATE }"
            ;;
        VPN*)
            fn_vpn="${line#VPN }"
            ;;
        LOAD*)
            fn_load="${line#LOAD }"
            ;;
        WEATHER*)
            fn_weather="${line#WEATHER }"
            ;;
        MEM*)
            fn_mem="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_mem}%{F- T1} ${line#MEM }"
            ;;
        CPU*)
            fn_cpu="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_cpu}%{F- T1} ${line#CPU }"
            ;;
        FREE*)
            fn_space="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_space}%{F- T1} ${line#FREE }"
            ;;
        MARKET*)
            #fn_crpt="%{F${color_sec_b2}}${sep_left}%{F- B${color_sec_b2} T1} ${line#MARKET } "
            fn_crpt="${line#MARKET }"            
            #fn_crpt="${fn_crpt/%'|'/}"
            #fn_crpt="${fn_crpt//'|'/}"
            ;;
        WIN*)            
            num_title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2 | wc -c)

            if (( num_title > 30 )); then
                name="$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2 | head -1 | head -c 30)..."
            else
                name="$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)"
            fi
            title="%{F${color_sec_b2} B${color_sec_b2}}${sep_right}%{F- B${color_sec_b2} T1} ${name} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} "
            ;;
    esac
    #printf "%s\n" "%{l}${fn_work}${title}%{S1}${fn_work}${title} %{S0}%{r}${fn_music}${stab}${fn_space}${stab}${fn_mem}${stab}${fn_cpu}${stab}${fn_load}${fn_vpn}${fn_weather}${fn_update}${fn_vol}${fn_date}${stab}${fn_time}%{S1}${fn_vol}${fn_date}${stab}${fn_time}"
    printf "%s\n" "%{l}${fn_work}${title}%{S1}${fn_work}${title} %{S0}%{r}${fn_music}${stab}${fn_vpn}${fn_weather}${fn_update}${fn_sync}${fn_vol}${fn_date}${stab}${fn_time}%{S1}${fn_vol}${fn_date}${stab}${fn_time}"
done < "${PANEL_FIFO}" | lemonbar -f "${FONTS}" -f "${ICONFONTS}" -g "${GEOMETRY}" -B "${BBG}" -F "${BFG}" | sh > /dev/null