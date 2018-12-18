#!/usr/bin/env perl

use strict;
use warnings;
use Capture::Tiny qw(capture);
#use List::MoreUtils qw(firstidx);

my $title = "VPN Menu";
#my $color_normal = "argb:0023262f, argb:F2a3be8c, argb:0023262f, argb:F2a3be8c, argb:F223262f";
#my $color_window = "argb:D923262f, argb:F2ffffff, argb:F2ffffff";
my $options = "-width -30 -location 3 -bw 1 -dmenu -i -p \"$title\" -lines 10"; # -color-window \'$color_window\' -color-normal \'$color_normal\' -font \'Inconsolata 11\'";
my $menu = "";

sub get_cur_vpn {
	my $cons = capture { system qq{nmcli -t -f name,type,device con | grep vpn | grep enp9s0}};
	
	my @name = split(":", $cons);
	my $val = $name[0];
	
	if(length $val gt 0){
		return $val;
	}
	
	return "EMPTY";
}

sub connected{
	if(-d "/proc/sys/net/ipv4/conf/tun0"){
		return 1;
	}
	elsif(-d "/proc/sys/net/ipv4/conf/ppp0" ){
		return 1;
	}
	else{
		return 0;
	}
}
sub get_item {
	my $cons = capture { system qq{nmcli -t -f name,type con | grep vpn}};
	my @items = split("\n", $cons);
	my $cur_con = "";
	
	if(connected) {
		$cur_con = get_cur_vpn;
	}

	foreach my $x (@items) {
		my @arr = split(":", $x);
		
		if($arr[0] eq $cur_con){
			$menu .= $arr[0] . "*\n";			
		} else {
			$menu .= $arr[0] . "\n";
		}
	}
	
	chomp($menu);
	
	my $var = capture { system qq{echo \"$menu\" | sort | rofi $options}};	
	chomp $var;		
	return $var;
}

sub handle_item {
	my $selection = $_[0];
	#my $int = firstidx { $_ eq $selection } @menu;
	#my $item = $menu[$int];
	$selection =~ s/\*//;
	chomp($selection);
	
	if(length $selection gt 0){
		if(connected){
			if($selection eq get_cur_vpn){
				print "Disconnecting from \"$selection\"\n";
				system qq{nmcli con down id \"$selection\"};
			}
		} else {
			print "Connecting to VPN \"" . $selection . "\"\n";
			my $res = capture { system qq{nmcli con up id \"$selection\"} };

			if($res =~ /activated/){
				system qq{notify-send -u normal -a "VPN Menu" "$selection" "Connection successfully activated"};
			} else {
				system qq{notify-send -u normal -a "VPN Menu" "$selection" "Connection Failed (check config)"};
			}
			
		}
	}
}

handle_item(get_item);