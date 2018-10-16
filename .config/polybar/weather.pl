#!/usr/bin/env perl

use strict;
use warnings;
use XML::LibXML;
use Capture::Tiny qw(capture);

my $METRIC = 1;
my $COUNTRY = "AU";
my $CITY = "BALAKLAVA";
my $LANG = "EN";
my $CODE = "41930";

sub get_url {
	my $url = capture { system qq{curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=$METRIC&locCode=$LANG|$COUNTRY|$CODE|$CITY"} };
	return $url;
}	

my $num = @ARGV;

sub check_condition {
	my $str;
	
	if($_[0] =~ /Sunny/ || $_[0] =~ /Intermittent/ || $_ [0] =~ /Hazy/ || $_[0] =~ /Hot/) 
	{ $str = ""; }
	elsif($_[0] =~ /Cloudy/ || $_[0] =~ /Dreary (Overcast)/ || $_[0] =~ /Fog/) 
	{ $str = ""; }
	elsif( $_[0] =~ /Showers/ || $_[0] =~ /T-Storms/ || $_[0] =~ /Rain/)
	{ $str= ""; }
	elsif( $_[0] =~ /Windy/)
	{ $str= ""; } 
	elsif($_[0] =~ /Flurries/ || $_[0] =~ /Snow/ || $_[0] =~ /Ice/ || $_[0] =~ /Sleet/ || $_[0] =~ /Rain/ || $_[0] =~ /Cold/)
	{ $str = ""; }
	if($_[0] =~ /Clear/ || $_[0] =~ /Moonlight/ || $_[0] =~ /Intermittent/)
	{ $str .= ""; }
	chomp($str);

	return $str;
}

sub get_weather {
	my $url = get_url;

	while(length $url lt 1){
		$url = get_url;
	}

	my $xml = XML::LibXML->load_xml(string=>get_url);
	my $str;
	foreach my $title ($xml->findnodes('/rss/channel/item/title')) {
		if($title =~ /Currently/){
			my @arr = split(/:/, $title->to_literal());
			$arr[1] =~ s/^\s+//;			
			$str = join("", check_condition($arr[1]),$arr[2]);
		}    	
	}	
	return $str;
}

print get_weather . "\n";