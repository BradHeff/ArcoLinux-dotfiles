#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Capture::Tiny qw(capture);

sub check_status {
	if ( -d "/proc/sys/net/ipv4/conf/tun0" ) {
		return 1;
	} elsif ( -d "/proc/sys/net/ipv4/conf/ppp0" ) {
		return 1;
	} else {
		return 0;
	}	
}

sub get_cur_con {
	my $con = capture { system qq{nmcli -t -f name,type,device con | grep vpn | grep enp9s0} };
	my ($name, $type, $dev) = split(":", $con);
	if (length($name) > 1){
		return $name;
	}
	return "Australia,Melbourne-udp";
}

sub sel_con {
	my $con = capture { system qq{nmcli -t -f name,type con | grep vpn} };
	my @cons = split("\n", $con);
	
	my $arnum = scalar(grep {defined $_} @cons), "\n";
	
	if($arnum > 1) {
		$con = $cons[int(rand(@cons))];		
	}
	
	my ($name, $type) = split(":", $con);
	if (length($name) > 1){
		return $name;
	}
	return "Australia,Melbourne-udp";
}

sub vpn_on {
	my $name = sel_con;
	my $result = capture { system qq{nmcli con up id $name} };
	if($result =~ /activated/){
		system qq{notify-send -u normal -a "VPN Menu" "$name" "Connection successfully activated"};
	} else {
		system qq{notify-send -u normal -a "VPN Menu" "$name" "Connection Failed (check config)"};
	}
}

sub vpn_off {
	my $name = get_cur_con;
	system qq{nmcli con down id $name};
}

if ( check_status == 0 ) {
    vpn_on;
}
else {
    vpn_off;
}
