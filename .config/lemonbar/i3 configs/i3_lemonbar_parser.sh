#!/bin/bash
#
# Input parser for i3 bar
# 14 ago 2015 - Electro7

# config
. $(dirname $0)/i3_lemonbar_config

# min init
irc_n_high=0
title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1}"
wspICO="%{F${color_back} B${color_wsp}} %{T2}${icon_wsp}%{T1}"
ws=""
count=0
# parser
while read -r line ; do
  case $line in
    SYS*)
      # conky=, 0 = wday, 1 = mday, 2 = month, 3 = time, 4 = cpu, 5 = mem, 6 = disk /, 7 = disk /home, 8-9 = up/down wlan, 10-11 = up/down eth, 12-13=speed
      sys_arr=(${line#???})
      # date
      if [ ${res_w} -gt 1024 ]; then
        date="${sys_arr[0]} ${sys_arr[1]} ${sys_arr[2]}"
      else
        date="${sys_arr[1]} ${sys_arr[2]}"
      fi
      date="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_clock}%{F- T1} ${date}"
      # time
      time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} ${sys_arr[3]} %{F- B-}"
      # cpu
      if [ ${sys_arr[4]} -gt ${cpu_alert} ]; then
        cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
      else
        cpu_cback=${color_sec_b2}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
      fi
      cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T1} ${sys_arr[4]}%"
      # mem
      mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T1} ${sys_arr[5]}"      
      # disk home
      diskh="%{F${color_icon}}${sep_l_left} %{T2}${icon_home}%{F- T1} ${sys_arr[6]}"
      # eth
      if [ "${sys_arr[7]}" == "down" ]; then
        ethd_v="×"; ethu_v="×";
        eth_cback=${color_sec_b1}; eth_cicon=${color_disable}; eth_cfore=${color_disable};
      else
        ethd_v=${sys_arr[7]}K; ethu_v=${sys_arr[8]}K;
        eth_cback=${color_sec_b1}; eth_cicon=${color_icon}; eth_cfore=${color_fore};
        
      fi
      ethd="%{F${eth_cback}}${sep_left}%{F${eth_cicon} B${eth_cback}} %{T2}${icon_dl}%{F${eth_cfore} T1} ${ethd_v}"
      ethu="%{F${eth_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${eth_cfore} T1} ${ethu_v}"
      ;;
    VOL*)
      # Volume
      vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} ${line#???}"
      ;;
    IRC*)
      # IRC highlight (script irc_warn)
      if [ "${line#???}" != "0" ]; then
        ((irc_n_high++)); irc_high="${line#???}";
        irc_cback=${color_chat}; irc_cicon=${color_back}; irc_cfore=${color_back}
      else
        irc_n_high=0; [ -z "${irc_high}" ] && irc_high="none";
        irc_cback=${color_sec_b2}; irc_cicon=${color_icon}; irc_cfore=${color_fore}
      fi
      irc="%{F${irc_cback}}${sep_left}%{F${irc_cicon} B${irc_cback}} %{T2}${icon_chat}%{F${irc_cfore} T1} ${irc_n_high} %{F${irc_cicon}}${sep_l_left} %{T2}${icon_contact}%{F${irc_cfore} T1} ${irc_high}"
      ;;
    MPD*)
      # Music
      mpd_arr=(${line#???})
      if [ -z "${line#???}" ]; then
        song="none";
      elif [ "${mpd_arr[0]}" == "error:" ]; then
        song="mpd off";
      else
        song="${line#???}";
      fi
      mpd="%{F${color_sec_b2}}${sep_left}%{B${color_sec_b2}}%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_music}%{F${color_fore} T1}  ${song}"
      ;;
    WSP*)
      count=$((count + 1))
      if [[ "$count" == "6" ]]; then
        wsp=""
        count=1
      fi
      set -- ${line#???}
      while [ $# -gt 0 ] ; do
        case $1 in
          FOC*)
            wsp="${wsp}%{F${color_wsp} B${color_head}}${sep_right}%{F${color_back} B${color_head} T1} ${1#???} %{F${color_head} B${color_wsp}}${sep_right}"
          ;;
          INA*)
            wsp="${wsp}%{F${color_disable} T1} ${1#???} "
          ;;
        esac
      shift
      done
      ;;
    WIN*)
      # window title
      title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      #title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2} T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      ;;
  esac
  blank="%{F${color_wsp} B${color_back}}${sep_right}%{F- B- T1} "
  # And finally, output
  printf "%s\n" "%{l}${wspICO}${wsp}${blank} %{r}${mpd}${stab}${cpu}${stab}${mem}${stab}${diskh}${stab}${ethd}${stab}${ethu}${vol}${stab}${date}${stab}${time}"
  #printf "%s\n" "%{l}${wsp}${title}"

done
