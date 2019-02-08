#!/usr/bin/env perl

use strict;
use warnings;
use Capture::Tiny qw(capture);


my $DIRS = "/home/pheonix/Pictures/Walls";

my $title = "Wallpapers";
my $options = "-width -30 -location 3 -dmenu -i -p \"$title\" -lines 10 -theme ~/.cache/wal/colors-rofi-dark.rasi";
my $is2bwm = capture{ system q{ps | grep i3 | wc -l}};

print "IS 2BWM:" . $is2bwm;

sub get_list {
	opendir(DIR, $DIRS);
	my @png = grep(/\.png$/,readdir(DIR));
	closedir(DIR);

	opendir(DIRS, $DIRS);
	my @jpg = grep(/\.jpg$/,readdir(DIRS));
	closedir(DIRS);

	my @files;
	push(@files, @png);
	push(@files, @jpg);

	my @sorted = sort @files;

	my $menu = "";
	for my $file (@sorted) {
		$menu .= $file . "\n";
	}

	chomp $menu;
	my $var = capture { system qq{echo \"$menu\" | sort | rofi $options}};
	chomp $var;

	return $var;
}

sub handle_item {
	my $selection = $_[0];
	chomp($selection);
	if(length $selection gt 0){
		my $command = qq{wal -i } . $DIRS . qq{/} . $selection;
		my $kill =  q{sh $HOME/.bin/lemon kill};
		my $lemon;
		if(length $is2bwm gt 1){
			$lemon = q{sh $HOME/.config/lemonbar/run_lemonbar2.sh};
		}
		else {
			$lemon = q{sh $HOME/.config/lemonbar/run_lemonbar.sh};
		}

		system qq{$command};
		system qq{$kill};
		system qq{$lemon};

		exit;
	}
}

handle_item(get_list);
