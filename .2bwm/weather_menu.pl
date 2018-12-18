#!/usr/bin/env perl

use strict;
use warnings;
use XML::LibXML;
use Capture::Tiny qw(capture);
use utf8;

my $METRIC = 1;
my $COUNTRY = "Au";
my $CITY = "Balaklava";
my $LANG = "EN";
my $CODE = "41930";

my $titles = $CITY . " " . $COUNTRY;
my $options = "-width -30 -location 3 -bw 1 -dmenu -i -p \"$titles\" -lines 3";

sub get_url {
	my $url = capture { system qq{curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=$METRIC&locCode=$LANG|$COUNTRY|$CODE|$CITY"} };
	return $url;
}	

sub get_icon {
	my $str;

	if( $_[0] =~ /Showers/i || $_[0] =~ /Rain/i || $_[0] =~ /Flurries/i || $_[0] =~ /Snow/i || $_[0] =~ /Ice/i || $_[0] =~ /Sleet/i || $_[0] =~ /Cold/i )
	{ $str= ""; }
	elsif( $_[0] =~ /T-Storms/i || $_[0] =~ /Thunderstorms/i )
	{ $str = ""; }
	elsif( $_[0] =~ /Sunny/i || $_[0] =~ /Intermittent/i || $_[0] =~ /Hazy/i || $_[0] =~ /Hot/i || $_[0] =~ /Clear/i || $_[0] =~ /Sunshine/i ) 
	{ $str = ""; }
	elsif( $_[0] =~ /Moonlight/i || $_[0] =~ /Intermittent/i )
	{ $str = ""; }
	elsif( $_[0] =~ /Cloudy/i || $_[0] =~ /Dreary/i || $_[0] =~ /Fog/i || $_[0] =~ /Cloudiness/i )
	{ $str = ""; }
	elsif( $_[0] =~ /Windy/i )
	{ $str= ""; } 	
	else
	{ $str = ""; }

	return $str;
}

sub check_weather {
	if( $_[0] =~ /Showers/i || $_[0] =~ /Rain/i || $_[0] =~ /Flurries/i || $_[0] =~ /Snow/i || $_[0] =~ /Ice/i || $_[0] =~ /Sleet/i || $_[0] =~ /Cold/i )
	{ return 0; }
	elsif( $_[0] =~ /T-Storms/i || $_[0] =~ /Thunderstorms/i )
	{ return 1; }
	elsif( $_[0] =~ /Sunny/i || $_[0] =~ /Intermittent/i || $_[0] =~ /Hazy/i || $_[0] =~ /Hot/i || $_[0] =~ /Clear/i || $_[0] =~ /Sunshine/i ) 
	{ return 0; }
	elsif( $_[0] =~ /Moonlight/i || $_[0] =~ /Intermittent/i )
	{ return 0; }
	elsif( $_[0] =~ /Cloudy/i || $_[0] =~ /Dreary/i || $_[0] =~ /Fog/i || $_[0] =~ /Cloudiness/i )
	{ return 0; }
	elsif( $_[0] =~ /Windy/i )
	{ return 1; } 	
	else
	{ return 1; }

	return 0;
}

sub get_weather {

	#=======================
	# 	    FETCH RSS
	#=======================	
	my $url = get_url;

	while(length $url lt 1){
		$url = get_url;
	}

	#=======================
	# 		LOAD VARS
	#=======================
	my $xml = XML::LibXML->load_xml(string=>$url);
	
	my $str1 = "";
	my $str2 = "";
	my $strn = "";
	my $strs = "";
	
	my $count = 0;

	my @arr;
	my @dec1;
	my @dec2;
	my @dot1;
	my @dot2;

	#=======================
	# 		  NOW
	#=======================
	my @t = $xml->findnodes('/rss/channel/item/title');	
	push (@arr, split(/:/, $t[0]));
	$arr[1] =~ s/^\s+//;
	$arr[2] =~ s/\s+//;
	$arr[2] =~ s/<.*//;
	$strn = get_icon($arr[1]);	
	$strs = "Now:        " . $strn . " " . $arr[2] . "\n";	

	#=======================
	# 		  TODAY
	#=======================	
	my @desc = $xml->findnodes('/rss/channel/item/description');		
	$desc[1] =~ s/[;].*//;
	$desc[1] =~ s/^[^>]*>//;
	$desc[1] =~ s/\s&lt//;
	$desc[2] =~ s/[;].*//;
	$desc[2] =~ s/^[^>]*>//;
	$desc[2] =~ s/\s&lt//;

	my $title = "Today:      ";
	push (@dot1, split(/C /, $desc[1]));
	push (@dec1, split(/,/, $dot1[2]));				

	$dot1[0] =~ s/\s//g;
	$dot1[1] =~ s/\s//g;
	$dec1[0] =~ s/^\s//;
	
	$str1 = get_icon($dec1[0]);
	
	$dot1[0] =~ s/^[^:]*://;
	$dot1[1] =~ s/^[^:]*://;
	
	$strs .= $title . $str1 . " " . $dot1[1] . "C / " . $dot1[0] . "C\n";
	
	#=======================
	# 		 TOMORROW
	#=======================	
	$title = "Tomorrow:   ";
	push (@dot2, split(/C /, $desc[2]));
	push (@dec2, split(/,/, $dot2[2]));				

	$dot2[0] =~ s/\s//g;
	$dot2[1] =~ s/\s//g;
	$dec2[0] =~ s/^\s//;
	
	$str2 = get_icon($dec2[0]);
	
	$dot2[0] =~ s/^[^:]*://;
	$dot2[1] =~ s/^[^:]*://;
	
	$strs .= $title . $str2 . " " . $dot2[1] . "C / " . $dot2[0] . "C\n";	
	chomp $strs;

	#=======================
	# 		SHOW MENU
	#=======================	
	my $var = capture { system qq{echo \"$strs\" | rofi $options}};
	chomp $var;

	#=======================
	# 	 CHECK SELECTION
	#=======================	
	if($var =~ /Now/i) {
		if(check_weather($arr[1])){
			system qq{notify-send -u normal -i messagebox_warning "$arr[1]" "$strn  $arr[2]"}
		}else{
			system qq{notify-send -u normal "$arr[1]" "$strn  $arr[2]"}
		}
		
	}
	elsif($var =~ /Today/i) {
		if(check_weather($dec1[0])){
			system qq{notify-send -u normal -i messagebox_warning "$dec1[0]" "$str1  $dot1[1]C / $dot1[0]C"}
		}
		else {
			system qq{notify-send -u normal "$dec1[0]" "$str1  $dot1[1]C / $dot1[0]C"}
		}
	}
	elsif($var =~ /Tomorrow/i) {
		if(check_weather($dec2[0])){
			system qq{notify-send -u normal -i messagebox_warning "$dec2[0]" "$str2  $dot2[1]C / $dot2[0]C"}
		}
		else {
			system qq{notify-send -u normal "$dec2[0]" "$str2  $dot2[1]C / $dot2[0]C"}
		}
	}
}

get_weather;