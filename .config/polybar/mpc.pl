#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use Capture::Tiny qw(capture);

# COLORS
my $color_lbl = '%{F#38d1b2} : ';
my $color_fgy = '%{F#E0B053} : ';
my $color_end = '%{F-}';
my $color_end2 = '...%{F-}';

# VARIABLS
my $NCMP;
my $NUM_NCMP;
my $S_NCMP;
my $NCMP_C;

sub set_variables {
	$NCMP = capture { system qq{mpc | grep \"\\[playing\\]\" | awk '{print \$1}' } };
	$NUM_NCMP = capture { system qq{mpc | head -1 | wc -c} };
	$S_NCMP = capture { system qq{mpc | head -1 | head -c 30} };
	$NCMP_C = capture { system qq{mpc current} };

	chomp($NCMP);
	chomp($NUM_NCMP);
	chomp($S_NCMP);
	chomp($NCMP_C);	
}


sub check_stat {
	set_variables;
	if($NCMP eq "\[playing\]") {
		if(int($NUM_NCMP) < 30) {
			return $color_lbl . $NCMP_C . $color_end;
		} else {
			return $color_lbl . $S_NCMP . $color_end2;
		}
	} else {
		return $color_fgy . 'Pause' . $color_end;
	}
}

say check_stat;