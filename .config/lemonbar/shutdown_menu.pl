#!/usr/bin/env perl

use strict;
use warnings;
use Capture::Tiny qw(capture);

my $title = "Menu";
my $color_normal = "argb:0023262f, argb:F2a3be8c, argb:0023262f, argb:F2a3be8c, argb:F223262f";
my $color_window = "argb:D923262f, argb:F2ffffff, argb:F2ffffff";
my $options = "-width -30 -location 5 -bw 1 -dmenu -i -p \"$title\" -lines 4 -color-window \'$color_window\' -color-normal \'$color_normal\' -font \'Inconsolata for Powerline 10\'";

sub get_item {
	my $RESULT = capture { system qq{sh /home/pheonix/.checksession} };
	my $items = "";
	chomp($RESULT);
	
	if($RESULT ne ""){
		$items = " Shutdown\n Reboot\n Suspend";
	}else{
		$items = " Shutdown\n Reboot\n Suspend\n Logout";
	}
	
		
	my $var = capture { system qq{echo \"$items\" | sort | rofi $options}};
	chomp $var;
	return $var;
}

sub handle_item {
	my $selection = $_[0];

	chomp($selection);
	
	if($selection =~ /Logout/){ 
		print "Logging Off\n";		
		system qq{i3_exit};		
	}
	elsif($selection =~ /Reboot/){
		print "Restarting\n";
		system qq{systemctl reboot};		
	}
	elsif($selection =~ /Shutdown/){
		print "Powering Off\n";
		system qq{systemctl poweroff};
	}
	elsif($selection =~ /Suspend/){
		print "Suspending System\n";
		system qq{systemctl suspend};
	}
}

handle_item(get_item);
