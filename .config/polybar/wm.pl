#!/usr/bin/env perl

use strict;
use warnings;
use Capture::Tiny qw(capture);

sub checkWS {
	my $string = "";
	for( my $i = 0; $i < 5; $i++ ) {
		if( $_[0] eq "$i" ) {
			$string .= "%{F#fcf529}  ●  %{F-}";
		}
		else{
			$string .= "%{F#66ffffff}  ●  %{F-}";
		}
	}
	return "$string";
}

sub getEnv{
	my $cmd = qq{xprop -root _NET_CURRENT_DESKTOP | sed -e 's/_NET_CURRENT_DESKTOP(CARDINAL) = //'};	
	my $WS = capture{ system qq{ $cmd } };
	chomp($WS);
	return "$WS";
}

print(checkWS(getEnv));