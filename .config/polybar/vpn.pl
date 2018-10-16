#!/usr/bin/env perl

use strict;
use warnings;


sub get_status {
	my $str;
	if(-d "/proc/sys/net/ipv4/conf/tun0"){
		$str = "%{u#f1ec54}%{F#f1ec54} On%{F-}%{u-}";
	}
	elsif(-d "/proc/sys/net/ipv4/conf/ppp0"){
		$str = "%{u#f1ec54}%{F#f1ec54} On%{F-}%{u-}";
	} else {
		$str = "%{F#E0B053} Off%{F-}";
	}
	return $str;
}

print get_status . "\n";