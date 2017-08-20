use strict;
use warnings;
use HTML::Entities;
use LWP::Simple;
open FO,">>helicopter_output";
print FO "innerlink\tREFERENCE\tTYPE\tCONSTRUCTOR\tMODEL\tVERSION\tREGISTRATION_NUMBER\tYEAR\n";
close FO;

for(my $i=1;$i<=65;$i++)
{
	#first page
	my $url="http://www.ga-market.com/search.php?search_type=7&type=7&tag=&lang=ENG&page=".$i;
	#print "$url\n";
	my $str=get($url);
	#print "$str\n";
	my($innerlink);
	
	while($str=~m/search_show_details"><a href="details_annonces-Helicopter-([^>]*?)\"/igs)
	{
		#second page(show details link)
		$innerlink="http://www.ga-market.com/details_annonces-Helicopter-".$1;
		print "$innerlink\n";
		#content of second page
		my $link1=get($innerlink);
		my($REFERENCE,$TYPE,$CONSTRUCTOR,$MODEL,$VERSION,$REGISTRATION_NUMBER,$YEAR);
		while($link1=~m/<div\s*id\=\"details_infos\">([\w\W]*?)<div id="repondre_annonce">/igs)
		{
			#block contains all information 
			my $block="$1";
			#print "$block\n";
			if($block=~m/class\=\"details\_title\">REFERENCE\s*<\/div>\s*<div\s*class\=\"details_description\">([^>]*?)\s*<\/div>/is)
			{
				$REFERENCE=decode_entities($1);
				print "$REFERENCE\n";
			}
			if($block=~m/TYPE<\/div>\s*<div\s*[\w\W]*?\">([^>]*?)<\/a>/is)
			{
				$TYPE=$1;
			}
			if($block=~m/CONSTRUCTOR<\/div>\s*<div\s*class\=[\w\W]*?>([^>]*?)<\/a>/is)
			{
				$CONSTRUCTOR=$1;
			}
			if($block=~m/MODEL<\/div>\s*<div\s*class\=[\w\W]*?>([^>]*?)<\/a>/is)
			{
				$MODEL=$1;
			}
			if($block=~m/VERSION<\/div>\s*<div\s*class\=[\w\W]*?>([^>]*?)<\/div>/is)
			{
				$VERSION=decode_entities($1);
			}
			if($block=~m/REGISTRATION NUMBER<\/div>\s*<div\s*class\=[\w\W]*?>([^>]*?)<\/div>/is)
			{
				$REGISTRATION_NUMBER=decode_entities($1);
			}
			if($block=~m/YEAR<\/div>\s*<div\s*class\=[\w\W]*?>([^>]*?)<\/div>/is)
			{
				$YEAR=decode_entities($1);
			}
			
			open FO,">>helicopter_output";
			print FO "$innerlink\t$REFERENCE\t$TYPE\t$CONSTRUCTOR\t$MODEL\t$VERSION\t$REGISTRATION_NUMBER\t$YEAR\n";
			close FO;
	
		}
		# open FO,">>helicopter_output";
		# print FO "$innerlink\n";
		# close FO;
	}
}
