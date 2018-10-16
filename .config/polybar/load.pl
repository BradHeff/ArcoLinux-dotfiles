#!/usr/bin/env perl

use strict;
#use warnings;
use feature qw(say switch);
use Capture::Tiny qw(capture);


my $load = capture { system q{uptime | awk '{print $(NF-2)}'} };
$load =~ s/\,\s*$//g;

sub get_color {
	if ((shift) < 3.4) {
		return '%{F#E0B053}';
	}
	if ((shift) < 8.2) {
		return '%{F#38d1b2}';
	} 
	else {
		return '%{F#d7521a}';	
	}
}

say get_color . $load . '%{F-}';