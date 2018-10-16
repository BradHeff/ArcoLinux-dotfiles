#!/usr/bin/env perl

#		polybar text
#	%{F#f00}TEXT%{F-}

use strict;
use warnings;
use feature qw(say);
use Capture::Tiny qw(capture);

my $home;
my $root;
my $num_args = @ARGV;

sub get_home {
	$home = capture { system qq{df -h | grep '/home/' | awk '{print \$4}'} };
	$home =~ s/\s+//g;
	$home =~ s/G//g;
	return "$home GB";
}

sub get_root {
	$root = capture { system qq{df -h | grep '/sdb2' | awk '{print \$4}'} };
  	$root =~ s/\s+//g;
  	$root =~ s/G//g;
	return "$root GB";

}

if ($num_args != 0) {    
    exit;
}
else {
    
    #say " " . get_root . "   " . get_home;
    say " " . get_root;
    
}
