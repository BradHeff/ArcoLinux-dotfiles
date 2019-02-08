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

my $fg = capture { system q{cat ~/.cache/wal/colors.sh | grep foreground | sed "s/'/ /g" | awk '{print $2}'} };
my $bg = capture { system q{cat ~/.cache/wal/colors.sh | grep color1 | sed "s/'/ /g" | awk '{print $2}' | head -1} };
my $warnbg = capture { system q{cat ~/.cache/wal/colors.sh | grep color5 | sed "s/'/ /g" | awk '{print $2}'} };

chomp($warnbg);
chomp($bg);
chomp($fg);

sub get_url {
	my $url = capture { system qq{curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=$METRIC&locCode=$LANG|$COUNTRY|$CODE|$CITY"} };
	return $url;
}	

my $num = @ARGV;

sub get_weather {
	my $url = get_url;

	while(length $url lt 1){
		$url = get_url;
	}

	my $xml = XML::LibXML->load_xml(string=>$url);
	my $str = "";
	my $strs = $url;

	foreach my $title ($xml->findnodes('/rss/channel/item/title')) {
		if($title =~ /Currently/){

			my @arr = split(/:/, $title->to_literal());
			$arr[1] =~ s/^\s+//;
			$arr[2] =~ s/\s+//;
			
			if( $arr[1] =~ /Showers/ || $arr[1] =~ /Rain/ || $arr[1] =~ /Flurries/ || $arr[1] =~ /Snow/ || $arr[1] =~ /Ice/ || $arr[1] =~ /Sleet/ || $arr[1] =~ /Cold/ )
			{ $str= ""; }
			elsif( $arr[1] =~ /T-Storms/ || $arr[1] =~ /Thunderstorms/ )
			{ 
				$str = "";				
				#$strs = q{ %{F#FFf59360 T3}%{F#FF282A36 B#FFf59360 T2} } . $str . q{ %{T1}} . $arr[2] . q{ %{F#FF5d36ab B#FFf59360 T3}%{F- B#FF5d36ab T1}};
				$strs = qq{%{F$warnbg B$bg T3}%{F$fg B$warnbg T2}} . $str . q{%{F- T1} } . $arr[2] . qq{ %{F$bg B$warnbg T3}%{F- T1}};
				return $strs;
			}
			elsif( $arr[1] =~ /Sunny/ || $arr[1] =~ /Intermittent/ || $arr[1] =~ /Hazy/ || $arr[1] =~ /Hot/ || $arr[1] =~ /Clear/ || $arr[1] =~ /Sunshine/ ) 
			{ $str = ""; }
			elsif( $arr[1] =~ /Moonlight/ || $arr[1] =~ /Intermittent/ )
			{ $str = ""; }
			elsif( $arr[1] =~ /Cloudy/ || $arr[1] =~ /Dreary/ || $arr[1] =~ /Fog/ )
			{ $str = ""; }
			elsif( $arr[1] =~ /Windy/ )
			{ $str= ""; } 	
			else
			{ $str = ""; }
						
			
			$strs = qq{%{F$bg T3}%{F$fg B$bg T2}} . $str . q{%{F- T1} } . $arr[2] . qq{%{F$bg B$bg T3}%{F- T1}};
			#
			return $strs;
		}    	
	}
	return qq{%{F$bg T3}%{F$fg B$bg T1} [X] %{F-}ERR %{F$bg B$bg T3}%{F- T1}};
}

print get_weather . "\n";