#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use File::Find;
use File::Path;

my $dir = "/home/pheonix/.local/share/Trash/files/";
my $counter = 0;
my $isgone = 0;

my $nums = @ARGV;

if($nums == 1){
	if($ARGV[0] eq "--clean") {
		
		$isgone = 0;

		rmdir '/home/pheonix/.local/share/Trash/files';
		
		if(-e '/home/pheonix/.local/share/Trash/files') 
		{
			rmtree '/home/pheonix/.local/share/Trash/files';
		} else {
			mkdir '/home/pheonix/.local/share/Trash/files';
			$isgone = 1;
		}
		if ($isgone == 0) {
			mkdir '/home/pheonix/.local/share/Trash/files';
			$isgone = 1;
		}

	
		$isgone = 0;

		rmdir '/home/pheonix/.local/share/Trash/info';

		if(-e '/home/pheonix/.local/share/Trash/info') 
		{
			rmtree '/home/pheonix/.local/share/Trash/info';
		} else {
			mkdir '/home/pheonix/.local/share/Trash/info';
			$isgone = 1;
		}
		if($isgone == 0){
			mkdir '/home/pheonix/.local/share/Trash/info';
			$isgone = 1;
		}		
	}
} else {
	
	find(\&wanted, $dir);

	sub wanted {
	    -f && $counter++;
	}

	if ( $counter == 0 ) {
		say '%{u#d7521a}%{F#E0B053} 0%{F-}%{u-}';
	} else {
		say '%{u#d7521a}%{F#d7521a} ' . $counter . '%{F-}%{u-}';
	}
}