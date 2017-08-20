################################################
#Website Name: "http://www.yelp.com/"
#Last Modified name
#Last Modified:3/31/2016
#Missed to collect to website_link in Yelp_URL_Table_Proxy
#Value for descriptive address is placed in website_link  in Yelp_URL_Table_Proxy
#change the source url in Yelp_URL_Table_Proxy
################################################

use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::Escape;
use HTML::Entities;
use DBI;
use Encode;
use threads;
use Time::Piece;
use LWP::Simple;
my $ua=LWP::UserAgent->new;
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
my $cookie_jar = HTTP::Cookies->new(file=>$0."_cookie.txt",autosave => 1,);                    
$ua->cookie_jar($cookie_jar);
$cookie_jar->save;
open FH, ">Yelp_Output.txt";
print FH "sno\tYPID\tlisting_name\tstreet\tcity\tstate\tzip\tphone\tcap_title\tcap_street1\tcap_city1\tcap_state1\tcap_zip1\tcap_phone1\twebsite\tHours\tReviewers_Name\tLatest_Review_Date\tReview_content\tBusiness_Status\tCategory\tmain_url\tdetail_page_link\tcomp_rate\tcomp_bigram_rate\tstreetbigram_rate\tcity_bigram_rate\tstate_bigram_rate\tzip_token_rate\tphone_rate\tCode\tStaus\tstart_time\tend_time\tPublic_ip\tLocal_ip\n";
close FH;
#proxy settings
#$ua->proxy(['http', 'https'],"http://"."127.0.0.1:4001");  #for server
open FH, "<Sample_input.txt";
my ($public_ip,$local_ip)=ip();
my @arr=<FH>;
foreach (@arr)
{
	my ($YPID,$listing_name,$street,$city,$state,$zip,$country,$phone)=split("\t");
	my$sno;
	chomp($sno);chomp($YPID);chomp($listing_name);chomp($street);chomp($city);chomp($state);chomp($zip);chomp($phone);
	our $start_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
	my $number;
	my $extra_url;
	if($street=~m/^([\d]+)/is)
	{
		$number=$1;
	}
	###not in Use#########
	# if($state=~m/U([^>]*)/is)
	# {
		# $state=$1;
	# }
	############################
	my $location= "$city,$state";
	
	#print "######################################\n";
	print "$YPID => $listing_name\n"; #for checking
	print "$location\n";             #for checking 
	#print "######################################\n";
	 $location=uri_escape($location);
	my $flag=0;
	print "######### input token #########\n";
	#### Seperating the input name as token and store into an array
	my $company1="$listing_name";
	# $company1=~s/\b5\b/five/igs;
	# $company1=~s/\bMfg\b/Manufacturing/igs;
	$company1=&Tweek_Company($company1);
	my $ip_company_name=$company1;
	my $sep_token=seperating_token($company1);
	my @ip_name_token=@$sep_token;
	print "input name token=@ip_name_token\n";
	####
	#### Seperating the input address as token and store into an array
	
	my $street1="$number $street";
	print "----input address token=$street1\n";
	my $address2=lc (clean_text("$street1"));
	
	my $sep_token=seperating_token($address2);
	my @ip_address_token=@$sep_token;
	print "input address token=@ip_address_token\n";
	####
	#### Seperating the input city as token and store into an array
	my $city1 =lc("$city");
	$city1=~s/\bft\b/fort/igs;
	my $sep_token=seperating_token($city1);
	my @ip_city_token=@$sep_token;
	print "input city token=@ip_city_token\n";
	####
	#### Seperating the input state as token and store into an array
	my $state1=lc("$state");
	my $sep_token=seperating_token($state1);
	my @ip_state_token=@$sep_token;
	print "input state token=@ip_state_token\n";
	my $sep_token=seperating_token($zip);
	my @ip_zip_token=@$sep_token;
	print "input state token=@ip_zip_token\n";
	####
	#### Seperating the input phone as token and store into an array
	my $phone="$phone";
	my $ip_phone=$phone;
	# $ip_phone=~s/\-|\.//igs;
	print "input phone token=$phone\n";
	####
	print "######### input token #########\n";
	nextserch:
	$company1=uri_escape_utf8($listing_name);
	
    my $source_url="http://www.yelp.com/search?find_desc=$company1&ns=1&find_loc=$location";
	my $main_url=$source_url;
	sameinput:
	 print "\n<<< MAIN URL: $source_url >>>\n";<>;
	# my $con=&HideMyAss_Proxy_Content($source_url,'GET','','');	
	my $con=&getcont($source_url,'','','GET');	
	# $con=decode_entities($con);
	# open(FH,">$YPID content.html");
	# print FH $con;
	# close FH;
	# print "stop\n";<>;
	
		# my $count=0; 			 
		## Capturing the block	
		# $listing_name=~s/\'/\'\'/igs;$street=~s/\'/\'\'/igs;$city=~s/\'/\'\'/igs;$state=~s/\'/\'\'/igs;$zip=~s/\'/\'\'/igs;$phone=~s/\'/\'\'/igs;$extra_url=~s/\'/\'\'/igs;				
		if($con=~m/>\s*You\s*are\s*currently\s*using\s*our\s*</is)
		{
			 print "\n<<< ip  blocked >>>\n";
			  sleep(5);
			 goto sameinput;
			
			# my $con=&HideMyAss_Proxy_Content($source_url,'GET','','');		
		}
		elsif($con!~m/<\!DOCTYPE\s*HTML>/is)
		{
			 print "\n<<< Content  blank >>>\n";
			  sleep(5);
			 goto sameinput;
			
			# my $con=&HideMyAss_Proxy_Content($source_url,'GET','','');		
		}
		elsif($con=~m/<h1>\s*no\s*results[^<]*</is)
		{
			# my $qry = "insert into Tom_tom_yelp_Sample_output(SNO,YPID,LISTING_NAME,ADDRESS_TEXT,POSTAL_CITY,STATE,ZIP,PHONE_TEXT,EXTRA_URL,Comments) values(\'$sno\',\' $YPID\' , \'$listing_name\', \'$street\' , \'$city\' , \'$state\',\'$zip\',\'$phone\',\'$extra_url\',\'No Results\')";
			 my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
			open FH, ">>Yelp_Output.txt";				
			print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t\t\t\t\t\t\t\t\t\t\t\t\t\t$main_url\t\t\t\t\t\t\t\t\tNo results\t$start_time\t$end_time\t$public_ip\t$local_ip\n";	
			close FH;		 
		}
		elsif($con=~m/<h2>We\'ve\s*found\s*multiple\s*locations\s*matching\s*your\s*search\.<\/h2>/is)
		{
			my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
			open FH, ">>Yelp_Output.txt";
			print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t\t\t\t\t\t\t\t\t$main_url\t\t\t\t\t\t\t\t\tNo Result(multiple)\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
			close FH;		
		}	
		else
		{
			my  $result_flag==0;
			my ($cap_link,$detail_link,$comp_rate,$phone_rate,$addr_rate,$city_rate,$state_rate,$cap_title,$comp_bigram_rate);
			my($cap_street,$cap_city,$cap_state,$cap_zip);
				my ($overall_status,$overall_token_score,$overall_bigram_score, $st_no_rate,$streetname_rate,$streetbigram_rate,$state_bigram_rate,$zip_bigram_rate,$city_bigram_rate,$cap_address);
			#my ( $cap_link, $comp_rate, $phone_rate, $addr_rate, $city_rate, $state_rate,$cap_title,$comp_bigram_rate,
			# $cap_street,$cap_city,$cap_state,$cap_zip,$cap_phone,$st_no_rate,$streetname_rate,$city_rate,$state_rate,$phone_rate,$comp_bigram_rate,$overall_status,$overall_token_score,$overall_bigram_score);
			# while($con=~m/(<h4\s*class=\"itemheading\"\s*id=\"bizTitle[^>]*?\">\s*[\w\W]*?href="[^~]*?)<\/address>\s*<\/div>/igs)
			# {
			while($con=~m/<h[\d]+\s*class=\"search\-result\-title\">([\w\W]*?<\/address>[\w\W]*?)<\/div>/igs)
			{
		
				my $block=$1;		
				### Capturing the company name and title
				#my ($cap_link,$comp_rate,$phone_rate,$addr_rate,$city_rate,$state_rate,$cap_title,$comp_bigram_rate);
				# if ($block=~m/<a\s*id=\"bizTitleLink[^>]*?\"\s*href=\"([^<]*?)\"[\w\W]*?highlighted\">([\W\w]*?)<\/a>/is)
				# {
				if ($block=~m/\=\"biz\-name"\s*href=\"([^<]*?)\"[^>]*?>([\W\w]*?)<\/a>/is)
				{
				
					$cap_link="$1";
					$cap_link=decode_entities("http://www.yelp.com"."$1");
					$cap_title=$2;
					$cap_title=~s/amp\;//igs;				 
					$cap_title=~s/<[^>]*?>/ /igs;
					$cap_title=~s/\s+/ /igs;
					$cap_title=~s/^\s*|\s*$//igs;

					print "==========Link=>$cap_link\n";
					print "==========Name=>$cap_title\n";
				
					### Calculating the token score for i/p name with captured name
					my $cap_comp_name="$cap_title";
					$cap_comp_name=&Tweek_Company($cap_comp_name);
					my $cap_comp_name1=$cap_comp_name;
					
					$comp_bigram_rate=&bigram_match($cap_comp_name1,$ip_company_name);

					my $sep_token=seperating_token($cap_comp_name);
					my @cap_name_token=@$sep_token;
					$comp_rate=token_score(\@ip_name_token,\@cap_name_token);
					#print "Captured Comp_name: @cap_name_token\n";
					print "-----3rd Party-Company token Rate =$comp_rate\n";
						
				}			 
				  ### Capturing the phone
				 my ($telephone,$cap_phone,$phone_rate);
				# if($block=~m/<div[^>]*?class\=\"phone\"[^>]*?>\s*([^<]*?)\s*</is)
				# {
				if($block=~m/<[^>]*?class\=\"[^>]*?phone\"[^>]*?>\s*([^<]*?)\s*</is)
				{
					$telephone=$1;
					### Calculating the token score for i/p phone with captured phone
					$cap_phone="$telephone";
					$phone_rate=seperating_phone_token($ip_phone,$cap_phone);
					
					print "-------3rd Party-Phone token Rate=$phone_rate\n";
				}
				  ### Capturing the address, city & state 
				

				if ($block=~m/<address>\s*(?:<[^>]*>)?([^<]*?)<br>([^<]*?)\,\s*([\w]{2})?\s*(?:([\d]{4,}))?/is)
				{
					$cap_street=$1;
					$cap_city=$2;
					$cap_state=$3;
					$cap_zip=$4;
					$cap_street=~s/amp\;/ /igs;
					$cap_street=~s/<[^>]*?>/ /igs;
					$cap_street=~s/\s+/ /igs;
					$cap_street=~s/^\s+//igs;
					$cap_street=~s/\s+$//igs;
					 # print "-----$cap_street\n";
					 # print "$cap_city\n";
					 # print "$cap_state\n";
					$cap_city=~s/\bft\b/fort/igs;
					  
					my $len_addr=@ip_address_token;
					if($len_addr==0) # if the input address is empty, then the token score is 0.
					{
					   $addr_rate=0;
					}
					### Calculating the token score for i/p address with captured address
					else
					{
						$cap_address="$cap_street";
						$cap_address=lc &clean_text($cap_address);
						my $sep_token=seperating_token($cap_address);
						my @cap_addr_token=@$sep_token;
						$addr_rate=token_score(\@ip_address_token,\@cap_addr_token);
						# $address_bigram_rate=&bigram_match($cap_address,$$address2);
						#print "Captured Address: @cap_addr_token\n";
					}	
					
					print "-----3rd Party-Address Token Rate=$addr_rate\n";
					
					my $len_city=@ip_city_token;
					if($len_city==0)# if the input city is empty, then the token score is 0.
					{
						$city_rate=0;
					}
					### Calculating the token score for i/p city with captured city
					else
					{
						my $cap_city="$cap_city";
						my $cap_city1=lc($cap_city);
						my $sep_token=seperating_token($cap_city);
						my @cap_city_token=@$sep_token;
						$city_rate=token_score(\@ip_city_token,\@cap_city_token);
						$city_bigram_rate=&bigram_match($cap_city1,$city1);
						#print "Captured City: @cap_city_token\n";
					}	
					
					print "------3rd Party-City Token Rate=$city_rate\n";
					
					my $len_state=@ip_state_token;
					if($len_state==0)# if the input state is empty, then the token score is 0.
					{
						$state_rate=0;
					}
					### Calculating the token score for i/p state with captured state
					else
					{
						my $cap_state="$cap_state";
						my $cap_state1=lc($cap_state);
						my $sep_token=seperating_token($cap_state);
						my @cap_state_token=@$sep_token;
						$state_rate=token_score(\@ip_state_token,\@cap_state_token);
						$state_bigram_rate=&bigram_match($cap_state1,$state1);
						#print "Captured State: @cap_state_token\n";
					}				
					print "----3rd Party-State Token Rate=$state_rate\n";
					
				}
				
				
				my $web_st_match=0;my $source_st_match=0;
				
				my $cap_street_name=$cap_street;
				my $cap_streetname1=lc &clean_text($cap_street_name);
				
				while($cap_streetname1=~m/\b([\d]+)\b/igs)
				{
					my $street_no=$1;
					#print "Street no:$street_no input\n";
					$web_st_match++;
					if($address2=~m/\b$street_no\b/is)
					{
						$source_st_match++;
						#print "Street no:$street_no matched\n";
					}
				}
				#print "******$web_st_match\t$source_st_match\n";
				if($web_st_match>0)
				{
					$st_no_rate=($source_st_match/$web_st_match)*100;
					print "Street_no_score::$st_no_rate\n";
				}
				else
				{
					$st_no_rate=0;
					print "Street_no_score::$st_no_rate\n";
				}
				
				# $cap_streetname1=~s/\b[\d]+\b//igs;			
				my $sep_token=seperating_token($cap_streetname1);
				my @cap_streetname_token=@$sep_token;			
				
				my $ip_street_name=$address2;
				my $ip_street_name1=lc &clean_text($ip_street_name);
				# $ip_street_name=~s/\b[\d]+\b//igs;			
				my $sep_token=seperating_token($ip_street_name);
				my @ip_streetname_token=@$sep_token;			

				$streetname_rate=token_score(\@ip_streetname_token,\@cap_streetname_token);
				my $streetbigram_rate=bigram_match($cap_streetname1,$address2);
				# my $zip_bigram_rate=&bigram_match($cap_zip,$zip);
				my $sep_token=seperating_token($cap_zip);
				my @cap_zip_token=@$sep_token;
				my $zip_token_rate=token_score(\@ip_zip_token,\@cap_zip_token);
				# print "streetname_rate::$streetname_rate\n";
				
				
				# print "comp_bigram_rate::$comp_bigram_rate\n";
				$comp_bigram_rate = sprintf("%.2f", $comp_bigram_rate);
				$streetbigram_rate=sprintf("%.2f", $streetbigram_rate);
				$state_bigram_rate=sprintf("%.2f", $state_bigram_rate);
				$zip_bigram_rate=sprintf("%.2f", $zip_bigram_rate);
				$city_bigram_rate=sprintf("%.2f", $city_bigram_rate);
				my $scorecount=1;
				print "comp_bigram_rate::$comp_bigram_rate\nstreetbigram_rate::$streetbigram_rate\nstate_bigram_rate::$state_bigram_rate\nzip_bigram_rate::$zip_token_rate\ncity_bigram_rate::$city_bigram_rate\n";
				if((( $comp_rate ==100) || ($comp_bigram_rate ==100 ))&& (($streetname_rate>=90)||($streetbigram_rate>=90))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate >=0) ))
				{	
					
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							# print "cap_link::$cap_link1\n";
							# print "stop\n";<>;
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{					
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="VH - Exact";
                        my $status="Very High confidence";						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
				
					}
					
						
					
				}
				# elsif(($comp_rate >=75 || $comp_bigram_rate>=75) && ($streetname_rate>=90 || $streetbigram_rate>=90)&&($city_rate==100 || $city_bigram_rate==100) && ($state_rate==100 || $state_bigram_rate=100) && ($zip_bigram_rate==100) && ($phone_rate==100 || ($phone_rate==0)))
				elsif(((( $comp_rate >=75)&&($comp_rate >100)) || (($comp_bigram_rate >=75 )&&($comp_bigram_rate >=100)))&& ((($streetname_rate>=70)&&($streetname_rate>100))||($streetbigram_rate>=70)&&($streetbigram_rate>100))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate>0) ))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							# print "$cap_link::$cap_link1\n";print "stop\n";<>;
							my $detailconpage=getcont($cap_link1,"","","GET");
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="HC1 - Good";
                        my $status="High confidence";  						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}			
				# elsif((($comp_rate >=75) ||($comp_bigram_rate>=75)) && (($streetname_rate>=70)||($streetbigram_rate>=70))&&($city_rate==100||$city_bigram_rate==100) && ($state_rate==100||$state_bigram_rate=100) && ($zip_bigram_rate==100) && ($phone_rate==100 || $phone_rate==0))
				elsif(((( $comp_rate >=75)&&($comp_rate >100)) || (($comp_bigram_rate >=75 )&&($comp_bigram_rate >=100)))&& (($streetname_rate==0)||($streetbigram_rate==0))&&(($city_rate==0)||($city_bigram_rate==0)) && (($state_rate==0)||($state_bigram_rate==0)) &&($zip_bigram_rate==0) && (($phone_rate==100)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							# print "$cap_link::$cap_link1\n";print "stop\n";<>;
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="HC2 - Good";
                        my $status="High confidence";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\tHigh confidence\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				# elsif((($comp_rate >=50) || ($comp_bigram_rate>=50)) && (($streetname_rate>=90)||($streetbigram_rate>=90))&&($city_rate==100||$city_bigram_rate==100) && ($state_rate==100||$state_bigram_rate=100) && ($zip_bigram_rate==100) && ($phone_rate==100 || $phone_rate==0))
				elsif(((( $comp_rate >=50)&&($comp_rate <75)) || (($comp_bigram_rate >=50 )&&($comp_bigram_rate <75)))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate>0) ))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							# print "cap_link::$cap_link1\n";print "stop\n";<>;
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{	
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="HC3 - Good";
                        my $status="High confidence ";						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				# elsif(($comp_rate >=50 || $comp_bigram_rate>=50) && (($streetname_rate>=50)||($streetbigram_rate>=50))&&($city_rate==100||$city_bigram_rate==100) && ($state_rate==100||$state_bigram_rate=100) && ($zip_bigram_rate==100) && ($phone_rate==100 || $phone_rate==0))
				elsif(((( $comp_rate >=75)&&($comp_rate <100)) || ($comp_bigram_rate >=75 )&&($comp_bigram_rate <100))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="MC1 - Eyeball";
                        my $status="Medium confidence ";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				elsif(((( $comp_rate >=75)&&($comp_rate <100)) || ($comp_bigram_rate >=75 )&&($comp_bigram_rate <100))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==0) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="MC2 - Eyeball";
                        my $status="Medium confidence ";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50 )&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="MC3 - Eyeball";
                        my $status="Medium confidence ";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				elsif((( $comp_rate <50)||($comp_bigram_rate <50))&&(($streetname_rate>65)||($streetbigram_rate>65))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_bigram_rate==100) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="MC4 - CN Not match";
                        my $status="Medium confidence ";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50)&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate==100)) &&($zip_bigram_rate==100) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="LC1 - Must Check";
                        my $status="Low  confidence";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				}
				###########completed
                elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50)&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate==100)) &&($zip_bigram_rate==100) && (($phone_rate>0)))
				{	
					my $detailcon=getcont($cap_link,"","","GET");
					$detailcon=decode_entities($detailcon);
					# $detailcon=decode_entities($detailcon);
					# open(FH,">$YPID detail1.html");
					# print FH $detailcon;
					# close FH;
					
					result:
					my $detail_page_link;
					if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
					{
						$detail_page_link=$1;
					}
					my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
					if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
					{
						$Hours=$1;
						$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
						$Hours=~s/<[^>]*?>/ /igs;
						$Hours=~s/\s+/ /igs;
						
					}
					if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
					{
						$website=$1;
						$website=~s/<[^>]*?>/ /igs;
						$website=~s/\s+/ /igs;
					}				
					if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
					{
						$cap_street1=$1;
						$cap_street1=~s/<[^>]*?>/ /igs;
						$cap_street1=~s/\s+/ /igs;
					}
					if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
					{
						$cap_city1=$1;
						$cap_city1=~s/<[^>]*?>/ /igs;
						$cap_city1=~s/\s+/ /igs;
						
					}	
					if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
					{
						$cap_state1=$1;
						$cap_state1=~s/<[^>]*?>/ /igs;
						$cap_state1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
					{
						$cap_zip1=$1;
						$cap_zip1=~s/<[^>]*?>/ /igs;
						$cap_zip1=~s/\s+/ /igs;
					}	
					if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
					{
						$cap_phone1=$1;
						$cap_phone1=~s/<[^>]*?>/ /igs;
						$cap_phone1=~s/\s+/ /igs;
					}					
					if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
					{
						$contact_name=$1;
						$contact_name=~s/<[^>]*?>/ /igs;
						$contact_name=~s/\s+/ /igs;
					}
					if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
					{
						$role=$1;
						$role=~s/<[^>]*?>/ /igs;
						$role=~s/\s+/ /igs;
					}
					my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
					if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
					{
						my $review_block=$1;
						if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
						{
							$Reviewers_Name=$1;
							$Reviewers_Name=~s/<[^>]*?>/ /igs;
							$Reviewers_Name=~s/\s+/ /igs;
						}
						if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
						{
							$Latest_Review_Date=$1;
							$Latest_Review_Date=~s/<[^>]*?>/ /igs;
							$Latest_Review_Date=~s/\s+/ /igs;
						}
						if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
						{
							$Review_content=$1;
							$Review_content=~s/<[^>]*?>/ /igs;
							$Review_content=~s/\s+/ /igs;
						}
						
					}
					if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
					{
						$Business_Status="Closed";
					}
					else
					{
						$Business_Status="";
					}
					if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
					{
						$category=$1;
						$category=~s/<[^>]*?>/ /igs;
						$category=~s/\s+/ /igs;
						
					}
					if($cap_street1 eq '')
					{
						# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
						# {
						if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
						{
							my $cap_link1=$1;
							$cap_link1=~s/amp;//igs;
							print "cap_link::$cap_link1\n";
							my $detailconpage=getcont($cap_link1,"","","GET");
							$detailconpage=decode_entities($detailconpage);
							# open(FH,">$YPID detail.html");
							# print FH $detailconpage;
							# close FH;
							# print "stop\n";<>;
							$detailcon=$detailconpage;
							goto result;
						}
					}
					else
					{
						my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                        my $code="LC2 - Must Check";
                        my $status="Low confidence";   						
						open FH, ">>Yelp_Output.txt";
						print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
						close FH;
						$flag=1;
						goto nextinput;
					}	
				
				} 				
			}	
			####copy completed############	
			if($flag==0)
			{
				&google_snippet_yelp($YPID,$listing_name,$street,$city,$state,$zip,$country,$phone);
				# my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');	
				# open FH, ">>Yelp_Output.txt";				
			    # print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t\t\t\t\t\t\t\t\t\t\t\t\t\t$main_url\t\t\t\t\t\t\t\t\tNo Match\t$start_time\t$end_time\n";	
			    # close FH;
				# print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t\t\t\t\t\t\t\t\t\t\t\t\t\t$main_url\t\t\t\t\t\t\t\t\t\t\t\n";
				# close FH;
				# goto nextinput;
			}
			nextinput:
		
		
	}	
	
}
	
sub google_snippet_yelp()
{
	my $YPID=shift;
	my $listing_name=shift;
	my $street=shift;
	my $city=shift;
	my $state=shift;
	my $zip=shift;
	my $country=shift;
	my $phone=shift;
	my %numbers=("one" => "first","two" => "second","three"=>"third","four"=>"fourth","five"=>"fifth","six"=>"sixth","seven"=>"seventh","eight"=>"eighth","nine"=>"nineth","ten"=>"tenth");
    my %us_country_code=("AL" => "Alabama","AK" => "Alaska","AZ" => "Arizona","AR" => "Arkansas","CA" => "California","CO" => "Colorado","CT" => "Connecticut","DE" => "Delaware","FL" => "Florida","GA" => "Georgia","HI" => "Hawaii","ID" => "Idaho","IL" => "Illinois","IN" => "Indiana","IA" => "Iowa","KS" => "Kansas","KY" => "Kentucky","LA" => "Louisiana","ME" => "Maine","MD" => "Maryland","MA" => "Massachusetts","MI" => "Michigan","MN" => "Minnesota","MS" => "Mississippi","MO" => "Missouri","MT" => "Montana","NE" => "Nebraska","NV" => "Nevada","NH" => "New Hampshire","NJ" => "New Jersey","NM" => "New Mexico","NY" => "New York","NC" => "North Carolina","ND" => "North Dakota","OH" => "Ohio","OK" => "Oklahoma","OR" => "Oregon","PA" => "Pennsylvania","RI" => "Rhode Island","SC" => "South Carolina","SD" => "South Dakota","TN" => "Tennessee","TX" => "Texas","UT" => "Utah","VT" => "Vermont","VA" => "Virginia","WA" => "Washington","WV" => "West Virginia","WI" => "Wisconsin","WY" => "Wyoming","AS" => "American Samoa","DC" => "District of Columbia","FM" => "Federated States of Micronesia","GU" => "Guam","MH" => "Marshall Islands","MP" => "Northern Mariana Islands","PW" => "Palau","PR" => "Puerto Rico","VI" => "Virgin Islands","AE" => "Armed Forces Africa","AA" => "Armed Forces Americas","AE" => "Armed Forces Canada","AE" => "Armed Forces Europe","AE" => "Armed Forces Middle East","AP" => "Armed Forces Pacific");

    my %us_country_code_rev = reverse %us_country_code;
	our $start_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
	# my ($YPID,$listing_name,$street,$city,$state,$zip,$country,$phone)=split("\t");
	my$sno;
	chomp($sno);chomp($YPID);chomp($listing_name);chomp($street);chomp($city);chomp($state);chomp($zip);chomp($phone);
	# my $start_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
	# my $start_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
	my $flag=0;
	my $number;
	my $extra_url;
	if($street=~m/^([\d]+)/is)
	{
		$number=$1;
	}
	if($state=~m/U([^>]*)/is)
	{
		$state=$1;
	}
	my $location= "$listing_name $street $city $state $zip";
	my $search_term="$location site:yelp.com";
	$search_term=~s/\s+/ /igs;
	print "\n**$search_term**\n";
	$search_term=~s/\&/and/igs;
	# print "input_name::$input_name\n";<>;
	my $count=0;
	my $main_url="https://www.google.com/search?&output=search&sclient=psy-ab&q=".URLEncode($search_term)."&btnK=";
	# my $url1 ="https://www.google.com/search?&output=search&sclient=psy-ab&q=$search_term&btnK=";
	# print "url::$url1\n";
	my $url1=$main_url;
	my $con=&getcont1($main_url,'','','GET');	
	$con=decode_entities($con);
		# my $main_cont=&HideMyAss_Proxy_Content($url1,'GET','','');		
		# $main_cont=decode_entities($main_cont);
		# open IL,">$YPID g_content.html";
		# print IL $con;		
		# close IL;
		# print "stop\n";<>;
		while($con=~m/<h[\d]+\s*[^<]*?class\=[^>]*?>\s*<a\s*href\=\"([^>]*?)\">([\w\W]*?)<\/h3>\s*<div\s*class\=[^>]*?>\s*<div\s*class\=[^>]*?>\s*<cite>([\w\W]*?)<\/cite>[\w\W]*?<\/span>([\w\W]*?)<\/span>/igs)
		{

			my $link=$1;
			my $name=$2;
			my $domain=$3;
			my $snippet=$4;
			$name=~s/<[^>]*?>/ /igs;
			$name=~s/LinkedIn/ /igs;
			# $name=~s/profiles/ /igs;
			$name=~s/\||\#/ /igs;
			# $name=~s/\&/and/igs;
			$name=~s/\s+$//igs;
			$name=~s/^\s+//igs;
			# $name=~s/\s+/ /igs; 
			$domain=~s/<[^>]*?>//igs;
			$domain=~s/\s+/ /igs; 
			
			# $snippet1=~s/<[^>]*?>/ /igs;
			# $snippet1=~s/\s+/ /igs; 
			$snippet=~s/<[^>]*?>/ /igs;
			$snippet=~s/\s+/ /igs; 
			$name=~s/\||\)|\(|\+|\// /igs;
			$name=~s/\||\)|\(|\+|\$/ /igs;
			$snippet=~s/\||\)|\(|\+|\$|\>|\<|\!/ /igs;
			$snippet=~s/\||\)|\(|\+|\// /igs;
			my $snippet1=$snippet;
			$snippet=~s/\,|\.|\;/ /igs;
			$street=~s/\,|\.|\;/ /igs;
			# $snippet1=~s/\.|\;/ /igs;
			$street=~s/\s+/ /igs;
			$street=~s/^\s+//igs;
			$street=~s/\s+$//igs;
			# print "name::$name\n";<>;
			my($out_first_name,$out_lastname,$out_middle_name,$cap_title,$cap_address1);
			
			if($name=~m/([\d]{1}\s*\-[^>]*?)\-/is)
			{
				$cap_title=$1;
				$cap_title=~s/4/Four/igs;
				$cap_title=~s/\-//igs;
			}
			elsif($name=~m/([^>]*?)\-/is)
			{
				$cap_title=$1;
				$cap_title=~s/4/Four/igs;
				$cap_title=~s/\-/ /igs;
			}
			elsif($name=~m/([^>]*)/s)
			{
				$cap_title=$1;
				$cap_title=~s/4/Four/igs;
				$cap_title=~s/\-/ /igs;
			}
			
			$cap_title=~s/amp\;/ /igs;
			$cap_title=~s/\s+/ /igs;
			$cap_title=~s/^\s+//igs;
			$cap_title=~s/\s+$//igs;
			
			my($cap_street,$cap_city,$cap_state,$cap_zip);
			if($snippet=~m/($street)/is)
			{
				$cap_street=$1;
			}
			if($snippet=~m/\b($city)\b/is)
			{
				$cap_city=$1;
			}
			if($snippet=~m/\b($zip)\b/is)
			{
				$cap_zip=$1;
			}		
			if($snippet1=~m/\,\s*([A-z\s]*?)\s+([\d]{5})/s)
			{
				$cap_state=$1;
				
			}
			elsif($snippet1=~m/\,\s*([A-z\s]*?)\s+([\d\-]{9,10})/s)
			{
				$cap_state=$1;
				
			}
			
			# print "cap_street::$cap_street\ncap_city::$cap_city\ncap_state::$cap_state\ncap_zip::$cap_zip\n";
			my ($telephone,$cap_phone,$phone_rate);
			if($snippet=~m/([\d(\\)]{3,5}(?:\.|-|\s*)\s*[\d]{3}(?:\.|-|\s*)\s*[\d]{4})/is)
			{
				$telephone=$1;
				### Calculating the token score for i/p phone with captured phone
				$cap_phone="$telephone";
				$phone_rate=seperating_phone_token($phone,$cap_phone);	
				print "-------3rd Party-Phone token Rate=$phone_rate\n";
			}
			my $company1="$listing_name";
			# $company1=~s/\&/and/igs;
			print "cap_street::$cap_street\n";
			$cap_state=~s/\s+/ /igs;
			$cap_state=~s/^\s+//igs;
			$cap_state=~s/\s+$//igs;
			$cap_state= $us_country_code_rev{"$cap_state"};
			# print "cap_state::$cap_state\n";<>;
			
			$company1=~s/\b5\b/five/igs;
			$company1=~s/\bMfg\b/Manufacturing/igs;
			$company1=&Tweek_Company($company1);
			my $ip_company_name=$company1;
			my $sep_token=seperating_token($company1);
			my @ip_name_token=@$sep_token;
			print "input name token=@ip_name_token\n";
			####
			#### Seperating the input address as token and store into an array
			
			my $street1="$street";
			print "----input address token=$street1\n";
			my $address2=lc (clean_text("$street1"));
			my $sep_token=seperating_token($address2);
			my @ip_address_token=@$sep_token;
			print "input address token=@ip_address_token\n";
			####
			#### Seperating the input city as token and store into an array
			my $city1 =lc("$city");
			$city1=~s/\bft\b/fort/igs;
			my $sep_token=seperating_token($city1);
			my @ip_city_token=@$sep_token;
			print "input city token=@ip_city_token\n";
			####
			#### Seperating the input state as token and store into an array
			my $state1=lc("$state");
			my $sep_token=seperating_token($state1);
			my @ip_state_token=@$sep_token;
			print "input state token=@ip_state_token\n";
			####
			my $sep_token=seperating_token($zip);
			my @ip_zip_token=@$sep_token;
			#### Seperating the input phone as token and store into an array
			my $phone="$phone";
			my $ip_phone=$phone;
			print "input phone token=$phone\n";
			my ($detail_link,$comp_rate,$phone_rate,$addr_rate,$city_rate,$state_rate,$comp_bigram_rate);
					
			my ($overall_status,$overall_token_score,$overall_bigram_score, $st_no_rate,$streetname_rate);
			my $cap_comp_name="$cap_title";
			$cap_comp_name=&Tweek_Company($cap_comp_name);
			my $cap_comp_name1=$cap_comp_name;
			$comp_bigram_rate=&bigram_match($cap_comp_name1,$company1);
			my $sep_token=seperating_token($cap_comp_name);
			my @cap_name_token=@$sep_token;
			$comp_rate=token_score(\@ip_name_token,\@cap_name_token);
			#print "Captured Comp_name: @cap_name_token\n";
			print "-----3rd Party-Company token Rate =$comp_rate\n";
			print "-----3rd Party-Company bigram Rate =$comp_bigram_rate\n";
			my $cap_address="$cap_street";
			my $cap_address=lc &clean_text($cap_address);
			my $sep_token=seperating_token($cap_address);
			my @cap_addr_token=@$sep_token;
			my $streetbigram_rate;
			if($cap_address ne "")
			{
			  $streetname_rate=token_score(\@ip_address_token,\@cap_addr_token);
			  $streetbigram_rate=bigram_match($cap_address,$address2);
			}
			
			print "----- address token_score Rate =$addr_rate\n";
			print "----- addr_bigram_rate bigram Rate =$streetbigram_rate\n";
			# print "$cap_title\n$cap_state\n$cap_zip\n$cap_city\n$cap_street\n$cap_phone\n";<>;
			$cap_zip=~s/\-//igs;
			$zip=~s/\-//igs;
			my $cap_state="$cap_state";
			my $cap_state1=lc($cap_state);
			my $sep_token=seperating_token($cap_state);
			my @cap_state_token=@$sep_token;
			my $state_bigram_rate;
			if($cap_state ne "")
			{
			  $state_rate=token_score(\@ip_state_token,\@cap_state_token);
			  $state_bigram_rate=&bigram_match($cap_state1,$state1);
			}
			my $cap_city="$cap_city";
			my $cap_city1=lc($cap_city);
			my $sep_token=seperating_token($cap_city);
			my @cap_city_token=@$sep_token;
			my $city_bigram_rate;
			if($cap_city1 ne "")
			{
				$city_rate=token_score(\@ip_city_token,\@cap_city_token);
			    $city_bigram_rate=&bigram_match($cap_city1,$city1);
			}
			my $sep_token=seperating_token($cap_zip);
			my @cap_zip_token=@$sep_token;
			my $zip_token_rate;
			if($cap_zip ne "")
			{
			  $zip_token_rate=token_score(\@ip_zip_token,\@cap_zip_token);
			}
			
			 # my $zip_token_rate=&bigram_match($cap_zip,$zip);
			$comp_bigram_rate = sprintf("%.2f", $comp_bigram_rate);
			$streetbigram_rate=sprintf("%.2f", $streetbigram_rate);
			$state_bigram_rate=sprintf("%.2f", $state_bigram_rate);
			# $zip_token_rate=sprintf("%.2f", $$zip_token_rate);
			$city_bigram_rate=sprintf("%.2f", $city_bigram_rate);
			my $cap_link1=$link;
			
			# print "cap_link1::$cap_link1\n";<>;
			print "comp_bigram_rate::$comp_bigram_rate\nstreetbigram_rate::$streetbigram_rate\nstate_bigram_rate::$state_bigram_rate\nzip_bigram_rate::$zip_token_rate\ncity_bigram_rate::$city_bigram_rate\n";
			my $cap_link;
			#######changing
			if((( $comp_rate ==100) || ($comp_bigram_rate ==100 ))&& (($streetname_rate>=90)||($streetbigram_rate>=90))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate >=0) ))
			{	
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}	
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				
				if($cap_street1 eq '')
				{
					# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
					# {
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						$cap_link1="$cap_link1?sort_by=date_desc";
						# print "cap_link::$cap_link1\n";
						# print "stop\n";<>;
						my $detailconpage=getcont($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="VH - Exact";
                    my $status="Very High confidence";					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
				
				
			
			}
			
			elsif(((( $comp_rate >=75)&&($comp_rate >100)) || (($comp_bigram_rate >=75 )&&($comp_bigram_rate >=100)))&& ((($streetname_rate>=70)&&($streetname_rate>100))||($streetbigram_rate>=70)&&($streetbigram_rate>100))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate>0) ))
			{	
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
					# {
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "$cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="HC1 - Good";
                    my $status="High confidence ";  					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
				}	
			
			}			
		###completed
			elsif(((( $comp_rate >=75)&&($comp_rate >100)) || (($comp_bigram_rate >=75 )&&($comp_bigram_rate >=100)))&& (($streetname_rate==0)||($streetbigram_rate==0))&&(($city_rate==0)||($city_bigram_rate==0)) && (($state_rate==0)||($state_bigram_rate==0)) &&($zip_token_rate==0) && (($phone_rate==100)))
			{	
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
					# {
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "$cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="HC2 - Good";
                    my $status="High confidence";					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
				}	
			
			}
		    ########step1
			elsif(((( $comp_rate >=50)&&($comp_rate <75)) || (($comp_bigram_rate >=50 )&&($comp_bigram_rate <75)))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate>0) ))
			{	
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
					# {
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{	
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="HC3 - Good";
                    my $status="High confidence"; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
				}	
			
			}
		   ###step2
			elsif(((( $comp_rate >=75)&&($comp_rate <100)) || ($comp_bigram_rate >=75 )&&($comp_bigram_rate <100))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate>0)))
			{	
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					# if($detailcon=~m/<input\s*type\=\"text\"[^>]*?id\=\"hmainput\"\s*name\=[^>]*?value\=\"([^>]*?)\">/is)
					# {
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						print "cap_link::$cap_link1\n";
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						# print "stop\n";<>;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="MC1 - Eyeball";
                    my $status="Medium confidence "; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
				}	
		
			}
			#step3
			elsif(((( $comp_rate >=75)&&($comp_rate <100)) || ($comp_bigram_rate >=75 )&&($comp_bigram_rate <100))&& (($streetname_rate>75)||($streetbigram_rate>75))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==0) && (($phone_rate>0)))
			{
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="MC2 - Eyeball";
                    my $status="Medium confidence "; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
			}
			###copying
			##step4
			elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50 )&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate>0)))
			{
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="MC3 - Eyeball";
                    my $status="Medium confidence "; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
			}
			###cn1
			elsif((( $comp_rate <50)||($comp_bigram_rate <50))&&(($streetname_rate>65)||($streetbigram_rate>65))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate=100)) &&($zip_token_rate==100) && (($phone_rate>0)))
			{
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="MC4 - CN Not match";
                    my $status="Medium confidence "; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
			}
			#low
			elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50)&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate==100)||($city_bigram_rate==100)) && (($state_rate==100)||($state_bigram_rate==100)) &&($zip_token_rate==100) && (($phone_rate>0)))
			{
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="LC1 - Must Check";
                    my $status="Low  confidence  "; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
			}
			#low1
			elsif(((( $comp_rate >50)&&($comp_rate <75)) || ($comp_bigram_rate >50)&&($comp_bigram_rate <75))&& ((($streetname_rate>60)&&($streetname_rate<75))||($streetbigram_rate<75)&&($streetbigram_rate>60))&&(($city_rate<100)||($city_bigram_rate<100)) && (($state_rate==100)||($state_bigram_rate==100)) &&($zip_token_rate==100) && (($phone_rate>0)))
			{
				if($cap_link1=~m/[^>]*?\=(http[^>]*?)\&/is)
				{
					$cap_link=$1;
				}
				$cap_link="$cap_link?sort_by=date_desc";
				my $detailcon=getcont1($cap_link,"","","GET");
				$detailcon=decode_entities($detailcon);
				# $detailcon=decode_entities($detailcon);
				# open(FH,">$YPID detail1.html");
				# print FH $detailcon;
				# close FH;
				
				result:
				my $detail_page_link;
				if($detailcon=~m/<meta\s*property\=\"og\:url\"\s*content\=\"([^>]*?)\">/is)
				{
					$detail_page_link=$1;
				}
				my($Hours,$website,$cap_street1,$cap_city1,$cap_state1,$cap_zip1,$cap_phone1,$contact_name,$role);
				if ($detailcon=~m/<h3>\s*Hours\s*<\/h3>([\w\W]*?)<\/table>/is)
				{
					$Hours=$1;
					$Hours=~s/<th\s*scope\=\"row\">/\;/igs;
					$Hours=~s/<[^>]*?>/ /igs;
					$Hours=~s/\s+/ /igs;
					
				}
				if($detailcon=~m/>Business\s*website<\/span>([\w\W]*?)<\/a>/is)
				{
					$website=$1;
					$website=~s/<[^>]*?>/ /igs;
					$website=~s/\s+/ /igs;
				}				
				if($detailcon=~m/<span\s*itemprop\=\"streetAddress\">([\w\W]*?)<\/span>/is)
				{
					$cap_street1=$1;
					$cap_street1=~s/<[^>]*?>/ /igs;
					$cap_street1=~s/\s+/ /igs;
				}
				if($detailcon=~m/<span\s*itemprop\=\"addressLocality\">([\w\W]*?)<\/span>/is)
				{
					$cap_city1=$1;
					$cap_city1=~s/<[^>]*?>/ /igs;
					$cap_city1=~s/\s+/ /igs;
					
				}	
				if($detailcon=~m/<span\s*itemprop\=\"addressRegion\">([\w\W]*?)<\/span>/is)
				{
					$cap_state1=$1;
					$cap_state1=~s/<[^>]*?>/ /igs;
					$cap_state1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/<span\s*itemprop\=\"postalCode\">([\w\W]*?)<\/span>/is)
				{
					$cap_zip1=$1;
					$cap_zip1=~s/<[^>]*?>/ /igs;
					$cap_zip1=~s/\s+/ /igs;
				}	
				if($detailcon=~m/itemprop\=\"telephone\">([\w\W]*?)<\/span>/is)
				{
					$cap_phone1=$1;
					$cap_phone1=~s/<[^>]*?>/ /igs;
					$cap_phone1=~s/\s+/ /igs;
				}					
				if($detailcon=~m/\=\"user\-display\-name\">([^>]*?)</is)
				{
					$contact_name=$1;
					$contact_name=~s/<[^>]*?>/ /igs;
					$contact_name=~s/\s+/ /igs;
				}
				if($detailcon=~m/\="business\-owner\-role\">([^>]*?)</is)
				{
					$role=$1;
					$role=~s/<[^>]*?>/ /igs;
					$role=~s/\s+/ /igs;
				}
				my($Reviewers_Name,$Latest_Review_Date,$Review_content,$Business_Status,$category);
				if($detailcon=~m/<div\s*class\=\"media\-story\">([\w\W]*?)<div\s*class\=\"review\-footer\s*clearfix\">/is)
				{
					my $review_block=$1;
					if($review_block=~m/<li\s*class\=\"user\-name\">([\w\W]*?)<\/a>/is)
					{
						$Reviewers_Name=$1;
						$Reviewers_Name=~s/<[^>]*?>/ /igs;
						$Reviewers_Name=~s/\s+/ /igs;
					}
					if($review_block=~m/<meta\s*itemprop\=\"datePublished\"[^>]*?>([\w\W]*?)<\/span>/is)
					{
						$Latest_Review_Date=$1;
						$Latest_Review_Date=~s/<[^>]*?>/ /igs;
						$Latest_Review_Date=~s/\s+/ /igs;
					}
					if($review_block=~m/itemprop\=\"description\"[^>]*?>([\w\W]*?)<\/div>/is)
					{
						$Review_content=$1;
						$Review_content=~s/<[^>]*?>/ /igs;
						$Review_content=~s/\s+/ /igs;
					}
					
				}
				if($detailcon=~m/<\/i>\s*Yelpers[^>]*?location[^>]*?closed[^>]*?</is)
				{
					$Business_Status="Closed";
				}
				else
				{
					$Business_Status="";
				}
				if($detailcon=~m/<span\s*class\=\"category\-str\-list\">([\w\W]*?)<\/a>/is)
				{
					$category=$1;
					$category=~s/<[^>]*?>/ /igs;
					$category=~s/\s+/ /igs;
					
				}
				if($cap_street1 eq '')
				{
					if($detailcon=~m/parseURL\(\"([^>]*?)\"\)/is)
					{
						my $cap_link1=$1;
						$cap_link1=~s/amp;//igs;
						# print "cap_link::$cap_link1\n";print "stop\n";<>;
						my $detailconpage=getcont1($cap_link1,"","","GET");
						$detailconpage=decode_entities($detailconpage);
						# open(FH,">$YPID detail.html");
						# print FH $detailconpage;
						# close FH;
						$detailcon=$detailconpage;
						goto result;
					}
				}
				else
				{					
					my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');
                    my $code="LC2 - Must Check";
                    my $status="Low confidence"; 					
					open FH, ">>Google_Yelp_Output.txt";
					print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t$cap_title\t$cap_street1\t$cap_city1\t$cap_state1\t$cap_zip1\t$cap_phone1\t$website\t$Hours\t$Reviewers_Name\t$Latest_Review_Date\t$Review_content\t$Business_Status\t$category\t$main_url\t$detail_page_link\t$comp_rate\t$comp_bigram_rate\t$streetbigram_rate\t$city_bigram_rate\t$state_bigram_rate\t$zip_token_rate\t$phone_rate\t$code\t$status\t$start_time\t$end_time\t$public_ip\t$local_ip\n";
					close FH;
					$flag=1;
					goto nextinput;
			
				}
			}
			
			
			
			
			
			
			
		}
		if($flag==0)
		{
			my $end_time=localtime->strftime('%Y-%m-%d %H:%M:%S');	
			open FH, ">>Google_Yelp_Output.txt";				
			print FH "$sno\t$YPID\t$listing_name\t$street\t$city\t$state\t$zip\t$phone\t\t\t\t\t\t\t\t\t\t\t\t\t\t$main_url\t\t\t\t\t\t\t\t\tNo Match\t$start_time\t$end_time\t$public_ip\t$local_ip\n";	
			close FH;
			goto nextinput;
		}
}		
	
	
sub detailpage
{
	my $comp_bigram_rate=shift;
	my $con=shift;
	my $company1=shift;
	my $address2=shift;
	my $city1=shift;
	my $state1=shift;
	my $ip_phone=shift;
		
	
	my ($address_block,$cap_street,$cap_city,$cap_state,$cap_zip,$cap_phone);
				
	if($con=~m/<address\s*class\=\"adr\">([\w\W]*?)<\/address>/is)
	{
		$address_block=$1;
		
		if($address_block=~m/<span\s*class\=\"street\-address\">([^<]*)<\/span>/is)
		{
			$cap_street=$1;
		
		}
		if($address_block=~m/<span\s*class\=\"locality\">([^<]*)<\/span>/is)
		{
			$cap_city=$1;
		
		}
		if($address_block=~m/<span\s*class\=\"region\">([^<]*)<\/span>/is)
		{
			$cap_state=$1;
		
		}
		if($address_block=~m/<span\s*class\=\"postal-code\">([^<]*)<\/span>/is)
		{
			$cap_zip=$1;
		
		}				
	}
	if($con=~m/<span\s*id\=\"bizPhone\"\s*class\=\"tel\">([^<]*)<\/span>/is)
	{
		$cap_phone=$1;				
	
	}
	my $cap_street_name=$cap_street;
	my $cap_streetname1=lc &clean_text($cap_street_name);
	my $web_st_match=0;my $source_st_match=0;my $st_no_rate;
	while($cap_streetname1=~m/\b([\d]+)\b/igs)
	{
		my $street_no=$1;
		#print "Street no:$street_no input\n";
		$web_st_match++;
		if($address2=~m/\b$street_no\b/is)
		{
			$source_st_match++;
			#print "Street no:$street_no matched\n";
		}
	}
	if($web_st_match>0)
	{
		$st_no_rate=($source_st_match/$web_st_match)*100;
		print "Street_no_score::$st_no_rate\n";
	}
	else
	{
		$st_no_rate=0;
		print "Street_no_score::$st_no_rate\n";
	}
	
	$cap_streetname1=~s/\b[\d]+\b//igs;			
	my $sep_token=seperating_token($cap_streetname1);
	my @cap_streetname_token=@$sep_token;			
	
	my $ip_street_name=$address2;$ip_street_name=~s/\b[\d]+\b//igs;			
	my $sep_token=seperating_token($ip_street_name);
	my @ip_streetname_token=@$sep_token;			

	my $streetname_rate=token_score(\@ip_streetname_token,\@cap_streetname_token);
	
	print "streetname_rate::$streetname_rate\n";
	
	my $sep_token=seperating_token($city1);
	my @ip_city_token=@$sep_token;
	print "input city token=@ip_city_token\n";
	
	my $cap_city1="$cap_city";
	my $sep_token=seperating_token($cap_city1);
	my @cap_city_token=@$sep_token;
	my $city_rate=token_score(\@ip_city_token,\@cap_city_token);
	
	#### Seperating the input state as token and store into an array
	
	my $sep_token=seperating_token($state1);
	my @ip_state_token=@$sep_token;
	print "input state token=@ip_state_token\n";
	
	my $cap_state1="$cap_state";
	my $sep_token=seperating_token($cap_state1);
	my @cap_state_token=@$sep_token;
	my $state_rate=token_score(\@ip_state_token,\@cap_state_token);
	
	my $phone_rate=seperating_phone_token($ip_phone,$cap_phone);	
	my (@review_date,@review_description);

	return($cap_street,$cap_city,$cap_state,$cap_zip,$cap_phone,$st_no_rate,$streetname_rate,$city_rate,$state_rate,$phone_rate,$comp_bigram_rate,@review_description,@review_date);
	
	
}
		
sub bigram_match
{
	my $a1=shift;	my $b1=shift;
	
	match_loop:

	$a1 =~ s/\s//igs; $b1 =~ s/\s//igs;

	$a1 =~ s/\W//igs; $b1 =~ s/\W//igs;
	
	
	$a1=lc($a1);$b1=lc($b1);  

	my @a = split(//,$a1);

	my @b = split(//,$b1);

	my(@c,@d);

	for(my $i = 0; $i<= $#a; $i++)

	{

		my $j = $i+1;

		push(@c,"$a[$i]$a[$j]")  if( ($a[$i] ne "") && ( $a[$j] ne "") )  ;                                                                                       

	}             

	for(my $i = 0; $i<= $#b; $i++)
	{

		my $j = $i+1;

		push(@d,"$b[$i]$b[$j]") if( ($b[$i] ne "") && ($b[$j] ne "") );                      

	}              

	my $match = 0;
###########testing#################
	for(my $i = 0; $i<= $#c; $i++)

	{

		my $count = grep /$c[$i]/, @d;

		$match++            if( $count > 0 );

	}     
#########################################
	my $rate = ((2*$match)/($#c+$#d+2))*100;

	$rate = sprintf("%.2f",$rate);

	print "rate: $rate\n";   

	####### FOR SCORE >100 ########

	if($rate>100)

	{

		my $temp=$a1;

		$a1=$b1;

		$b1=$temp;

		undef @a;undef @b;undef @c;undef @d;

		goto match_loop;

	}              

	return $rate;

}	
	

##### Function for substituting st as street,rd as road,blvd as Boulevard etc.
sub Tweek_Company
{
my $company_name=shift;

$company_name=~s/\bLLC\b//igs;$company_name=~s/\bDDS\b//igs;$company_name=~s/\bThe\b//igs;$company_name=~s/\bPLLC\b//igs;$company_name=~s/\bCo\b//igs;$company_name=~s/\bPty\b//igs;$company_name=~s/\bLtd\b//igs;$company_name=~s/\bLimited\b//igs;$company_name=~s/\bCorp\b//igs;$company_name=~s/\bCorp\b\.//igs;$company_name=~s/\bCorporation\b//igs;$company_name=~s/\bCompany\b//igs;$company_name=~s/\bCo\b\.//igs;$company_name=~s/\bPtty\b//igs;$company_name=~s/\bLtd\b\.//igs;$company_name=~s/\bDMD\b//igs;$company_name=~s/\bDO\b//igs;$company_name=~s/\bMD\b//igs;$company_name=~s/\bIncorporated\b//igs;$company_name=~s/\bInc\b//igs;$company_name=~s/\bInc\\b\.//igs;$company_name=~s/\bPvt\b//igs;$company_name=~s/\bPTD\b//igs;$company_name=~s/\bP\/L\b//igs;$company_name=~s/\bPL\b//igs;$company_name=~s/\bCPA\b//igs;$company_name=~s/\bMr\b//igs;$company_name=~s/\bMrs\b//igs;$company_name=~s/\bDr\b//igs;$company_name=~s/\bAtty\b//igs;$company_name=~s/\bIntl\b//igs;$company_name=~s/\bJr\b\.//igs;$company_name=~s/\bSr\b\.//igs;$company_name=~s/\bI\b//igs;$company_name=~s/\bII\b//igs;$company_name=~s/\bIII\b//igs;$company_name=~s/\bSbe\b//igs;$company_name=~s/\bSdn\b//igs;$company_name=~s/\bAoc\b\.//igs;$company_name=~s/\bAssocation\b//igs;$company_name=~s/\bPrivate\b//igs;$company_name=~s/\bde\b//igs;$company_name=~s/\bAG\b//igs;$company_name=~s/\bCV\b//igs;$company_name=~s/\bSA\b//igs;$company_name=~s/\bPLC\b//igs;$company_name=~s/\bNV\b//igs;$company_name=~s/\bS\.A\b\.//igs;$company_name=~s/\bSPA\b//igs;$company_name=~s/\bN\.V\b\.//igs;$company_name=~s/\bLP\b//igs;$company_name=~s/\bMfg\b\.//igs;$company_name=~s/\bInv\b//igs;$company_name=~s/\bS\.R\.L\b\.//igs;$company_name=~s/\bS\.E\b\.//igs;$company_name=~s/\bNL\b//igs;$company_name=~s/\bPty\b\.//igs;$company_name=~s/\bOG\b//igs;$company_name=~s/\bAD\b//igs;$company_name=~s/\bGP\b//igs;$company_name=~s/\bLTDA\b\.//igs;$company_name=~s/\bCa\b\.//igs;$company_name=~s/\bd\.d\b\.//igs;$company_name=~s/\bk\.s\b\.//igs;$company_name=~s/\bv\.o\.s\b\.//igs;$company_name=~s/\bAy\b//igs;$company_name=~s/\bKy\b//igs;$company_name=~s/\bOy\b//igs;$company_name=~s/\bOyj\b//igs;$company_name=~s/\bKG\b//igs;$company_name=~s/\bKGaA\b//igs;$company_name=~s/\bPT\b//igs;$company_name=~s/\bS\.s\b\.//igs;$company_name=~s/\bS\.n\.c\b\.//igs;$company_name=~s/\bS\.a\.s\b//igs;$company_name=~s/\bS\.p\.A\b\.//igs;$company_name=~s/\bS\.a\.p\.a\b//igs;$company_name=~s/\bS\.c\.r\.l\b\.//igs;$company_name=~s/\bSIA\b//igs;$company_name=~s/\bAS\b//igs;$company_name=~s/\bIK\b//igs;$company_name=~s/\b+PS$\b//igs;$company_name=~s/\bKS\b//igs;$company_name=~s/\bUAB\b//igs;$company_name=~s/\bAB\b//igs;$company_name=~s/\bBhd\b\.//igs;$company_name=~s/\bS\.A\.B\b\.//igs;$company_name=~s/\bS\.A\.P\.I\b\.//igs;$company_name=~s/\bGte\b\.//igs;$company_name=~s/\bASA\b//igs;$company_name=~s/\bANS\b//igs;$company_name=~s/\bBA\b//igs;$company_name=~s/\bBL\b//igs;$company_name=~s/\bDA\b//igs;$company_name=~s/\bEtat\b//igs;$company_name=~s/\bFKF\b//igs;$company_name=~s/\bHF\b//igs;$company_name=~s/\bIKS\b//igs;$company_name=~s/\bKF\b//igs;$company_name=~s/\bNUF\b//igs;$company_name=~s/\bRHF\b//igs;$company_name=~s/\bSF\b//igs;$company_name=~s/\bSME\b//igs;$company_name=~s/\bCoop\b\.//igs;$company_name=~s/\bEnt\b\.//igs;$company_name=~s/\bP\.P\b\.//igs;$company_name=~s/\bCRL\b//igs;$company_name=~s/\bSGPS\b//igs;$company_name=~s/\bS\.C\.A\b\.//igs;$company_name=~s/\bS\.C\.S\b\.//igs;$company_name=~s/\bPte\b//igs;$company_name=~s/\bd\.o\.o\b\.//igs;$company_name=~s/\bd\.n\.o\b\.//igs;$company_name=~s/\bk\.d\b\.//igs;$company_name=~s/\bs\.p\b\.//igs;$company_name=~s/\bS\.L\b\.//igs;$company_name=~s/\bS\.L\.L\b\.//igs;$company_name=~s/\bS\.L\.N\.E\b\.//igs;$company_name=~s/\bS\.C\b\.//igs;$company_name=~s/\bS\.Cra\b\.//igs;$company_name=~s/\bS\.Coop\b\.//igs;$company_name=~s/\bOrg\b//igs;$company_name=~s/\bGRP\b//igs;$company_name=~s/\bGROUP\b//igs;$company_name=~s/\bEntreprise\b//igs;$company_name=~s/\bENTRPRS\b//igs;$company_name=~s/\bLL\b//igs;$company_name=~s/\bLL\b//igs;$company_name=~s/\bLL\b//igs;$company_name=~s/\bLL\b//igs;$company_name=~s/\bLL\b//igs;return $company_name;

}
sub clean_text
{
	my ($string) =@_;
	$string =~s/\-/ /igs;
	$string =~s/\.\s+/ /igs;
	$string =~s/\bw\b|\bw\.\b/west/igs;
	$string =~s/\bso\b|\bso\.\b|\bs\b/south/igs;
	$string =~s/\bav\b|\bAve\b|\bAve\.\b/Avenue/igs;
	$string =~s/\bmt\b|\bmtn\b/Mount/igs;
	$string =~s/\bwy\b/way/igs;
	$string =~s/\bpkwy\b|\bpkwy\.\b/parkway/igs;
	# $string =~s/\bhwy\b|\bhwy\.\b/highway/igs;
	$string =~s/\bPlace\b/pl/igs;
	$string =~s/\bstreet\b|\bst\.\b|\bst\b/st/igs;
	$string =~s/\bblvd\b|\bblvd\.\b/Boulevard/igs;
	$string =~s/\be\b|\be\.\b/east/igs;
	$string =~s/\bn\b|\bn\.\b/north/igs;
	$string =~s/\bnw\b|\bnw\.\b/northwest/igs;
	$string =~s/\bse\b|\bse\.\b/southeast/igs;
	$string =~s/\bsw\b|\bsw\.\b|\bs\.w\b|\bs\.w\b/southwest/igs;
	$string =~s/\bne\b|\bne\.\b|\bn\.e\b|\bn\.e\b/northeast/igs;
	$string =~s/\bnw\b|\bnw\.\b|\bn\.w\b|\bn\.w\b/northwest/igs;
	$string =~s/\brd\b|\brd\.\b|\brd\.\b|\brd\.\b/road/igs;
	$string =~s/\bintl\b|\bintl\.\b/international/igs;
	$string =~s/\bdr\b|\bdr\b/drive/igs;
	$string =~s/\brte\b|\brte\.\b|\brt\b|\brt\b/route/igs;
	$string =~s/\bbyp\b|\bbyp\b/bypass/igs;
	$string =~s/\bcir\b|\bcir\b/circle/igs;
	$string =~s/\btrl\b|\btrl\b/trial/igs;
	$string =~s/\be\b|\be\b/east/igs;
	$string =~s/\bexpy\b|\bexpy\b/expressway/igs;
	$string =~s/\bbld\b|\bbld\.\b|\bbldg\b|\bbldg\b/building/igs;
	$string =~s/\bln\b|\bln\b/lane/igs;
	$string =~s/\btnpk\b|\btnpk\.\b|\btnpke\b|\btnpke\b|\btpke\b/turnpike/igs;
	$string =~s/\bfway\b|\bfway\b|\bfwy\b/freeway/igs;
	$string =~s/\bEXP\b|\bEXP\b/EPRESS/igs;
	$string =~s/\bplz\b|\bplz\b/Plaza/igs;
	$string =~s/\bcntr\b|\bcntr\.\b|\bctr\b|\bctr\b/center/igs;
	$string =~s/\bcntr\b|\bcntr\.\b|\bctr\b|\bctr\b/centre/igs;
	$string =~s/\bsqr\b|\bsqr\b/square/igs;
	$string =~s/\bste\b|\bste\b/suite/igs;
	$string =~s/\bw\b|\bw\b/west/igs;
	$string =~s/\btwnshp\b|\btwnshp\.\b|\btwp\b|\btwp\b/township/igs;
	$string =~s/amp\;//igs;
	$string =~s/\bpo box\b|\bpobox\b|\bbox\b|\bp box\b|\bp\. box\b|\bpo\.box\b|\bp\.o\.box\b|\bp\.o\. box\b/PO Box/igs;
	$string =~s/\s+/ /igs;
	$string =~s/^ | $//igs;
	$string =~s/\bpk\b|\bpark\b/Park/igs;
	$string =~s/\bindustrial\b|\b ind\b/Industrial/igs;
	$string =~s/\bestate\b|\best\b/Estate/igs;
	$string=~s/\b(\d+)(?:st|rd|nd|th)\s+AVE\b|\b(\d+)(?:st|rd|nd|th)\s+AVE\s*\.\b|\b(\d+)(?:st|rd|nd|th)\s+AVENUE\b/$1$2$3 AVENUE/igs;
	$string=~s/\b(\d+)(?:st|rd|nd|th)\s+st\b|\b(\d+)(?:st|rd|nd|th)\s+st\s*\.\b|\b(\d+)(?:st|rd|nd|th)\s+street\b/$1$2$3 street/igs;
	return $string;
}

### Function for seperating inputs as token and store in an array
sub seperating_token
{
	my($string)=@_;
	$string=lc($string);
	$string=~s/\+/ /igs;
	$string=~s/\%26/\&/igs;
	$string=~s/\%27/\'/igs;
	$string=~s/\%40/\@/igs;
	$string=~s/<[^>]*?>//igs;
	$string=~s/\,|\-|\.|_|\// /igs;
	$string=~s/\'|\#|\@|\/|\;|\(|\)//igs;
	$string=~s/\&/and/igs;
	$string=~s/\s\s+/ /igs;
	$string=~s/^\s+|\s+$//igs;

	my @token=split(/ /,$string);
	return(\@token);
}	
### Function for seperating phone as token and store in an array

sub seperating_phone_token
{
	my($ip_token,$cap_token)=@_;
	$ip_token=~s/[^\d]*//igs;
	$cap_token=~s/[^\d]*//igs;
	my $rate;
	if($ip_token ne '')
	{
		if($ip_token eq $cap_token)
		{
			$rate="100";
		}
		else
		{
			$rate="0";
		}
	}	
	else
	{
		$rate="0";
	}
	return($rate);
}

#### Function for calculating token score 
sub token_score
{
	my($ip_token,$cap_token)=@_;
	my @ip_token=@$ip_token;
	my @cap_token=@$cap_token;
	my %seen = ();	 my %seen1 = ();	 my %seen2 = ();	my %seen3 = ();
	my @unique = grep { !$seen{$_}++} @ip_token;
	my @unique1 = grep { !$seen1{$_}++} @cap_token;
	my @unique2 = grep { $seen2{$_}++} @unique,@unique1;
	my @unique3 = grep { !$seen3{$_}++} @unique,@unique1;
	# print "\n<< @unique2\t@unique3<<";
	my $match=scalar(@unique2);
	my $count=scalar(@unique3);
	my $rate;
	eval
	{
	$rate=($match/$count)*100;
	};
	$rate = sprintf("%.2f",$rate);
	return($rate);
}
=e
sub database
{	
	my $query1 = shift;
	my $dbh1 = DBI->connect("dbi:ODBC:$dsn","$user","$pass") or die "\n$DBI::errstr\n";
	my $sth1 = $dbh1->prepare( $query1 );
 
	if($sth1->execute())
	{	
		print "<<< Inserted into database >>>\n";	
	}
	else
	{
		open(A,">>LogTime.txt");
		print A localtime() ."====>" . " ERROR IN DBI: (QUERY: $query1) " . $DBI::errstr . "\n";		
		close A;
	}
	$sth1->finish();
}
=cut
sub HideMyAss_Proxy_Content {
    use strict 'refs';
    my $Link = shift @_;
    $Link = &URLDecode($Link);
    $Link = decode_entities($Link);
    my $test = &URLEncode($Link);
    print "\nLink: $Link\n";
    Label: my $req = 'HTTP::Request'->new('POST', 'https://www.hidemyass.com/process.php');
    $req->header('Content-Type', 'application/x-www-form-urlencoded');
    $req->header('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    $req->header('Accept-Language', 'en-us,en;q=0.5');
    $req->header('Host', 'www.hidemyass.com');
    $req->header('Referer', 'http://www.hidemyass.com');
    $req->content("obfuscation=1&u=$test&x=20&y=21");
    my $res = $ua->request($req);
    my $code = $res->code;
    print "\nCODE:$code\n";
    my $cont = $res->content;
    if ($code =~ /^3/) {
        my $Re_Link = $res->header('Location');
        print "\nRedirected Link1: $Re_Link\n";
        my $host = &Extract_Domain("$Re_Link");
		# print "Re_Link::$Re_Link\n";<>;
        my $req = 'HTTP::Request'->new('GET', $Re_Link);
        my $res = $ua->request($req);
        my $code = $res->code;
        my $cont = $res->content;
        print "\nCODE:$code\n";
        if (not $code =~ /^2/ or $cont =~ /The\s*requested\s*resource\s*could\s*not\s*be\s*loaded|Hide\s*My\s*Ass\!\s*Free\s*proxy\s*node/is) {
            print "\nERROR in Content..\n";
            open f, '>Error_Pblm_HideMyAss.htm';
            print f "$cont";
            close f;
            goto Label;
        }
        return $cont;
    }
    elsif ($cont =~ /The\s*requested\s*resource\s*could\s*not\s*be\s*loaded/is) {
        print "\nERROR in Content..\n";
        open f, '>Error_Pblm_HideMyAss.htm';
        print f "$cont";
        close f;
        goto Label;
    }
    else {
        print "\n\nCheck Content..\n\n";
        open f, '>Not_300_HideMyAss.htm';
        print f "$cont";
        close f;
    }
}

############################################################        

sub URLEncode        # <space> to %20
{
        my ( $theURL ) = @_;                
        $theURL =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
        $theURL =~ s/\%20/\+/;
        return $theURL;
}

sub Extract_Domain
{
        my (  $theURL ) = @_;
        $theURL =~ s/^https?\:\/\///igs;        $theURL =~ s/^www(\d*)?\.//igs;                $theURL =~ s/\/.*$//igs;
        $theURL =~ s/\/$//igs;        $theURL =~ s/\.\s*$//igs;        $theURL =~ s/\s+/ /igs;
        return $theURL;
}

sub URLDecode
{
        my $theURL = $_[0];
        $theURL =~ tr/+/ /;
        $theURL =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
        $theURL =~ s/<!--(.|\n)*-->//g;
        return $theURL;
}
sub getcont()
{
    my $ur=shift;
    my $cont=shift;
    my $ref=shift;
    my $method=shift;
    my $count=0;	
	# sleep(int(rand(20)));
    netfail:
    my $request=HTTP::Request->new("$method"=>$ur);
    $request->header("Content-Type"=>"application/x-www-form-urlencoded; charset=UTF-8");
	# $request->header("Cookie"=>"PHPSESSID=jvlqqe9orhvc1ds1f97kaq29c7; srch_str=http://www.globalplanesearch.com/search?mk=776&region=Worldwide&cntry=Any&st=Any&syr=1&eyr=2020&spr=0&epr=999999999999&at=Any&ltfilt=&ut=&mf=&sort=default&shw=2000&cur=1&lsl=4&hsl=7&rs=0; srch_trm=Piper Aircraft Worldwide; __utma=55968765.71456008.1425107987.1425116125.1425122110.4; __utmc=55968765; __utmz=55968765.1425107987.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __gads=ID=d8ae6b0e21745cfd:T=1425107915:S=ALNI_MYV_zdS1zddM9SpNPrLm3PBPoL1eA; __utmb=55968765.19.10.1425122110; system=v2; gps_regis=1; __utmt=1");
     if($ref ne '')
	
    {
   
        $request->header("Referer"=>"$ref");
    }
    if(lc $method eq 'post')
    {
   
        $request->content($cont);
    }
    my $res=$ua->request($request);
    $cookie_jar->extract_cookies($res);
    $cookie_jar->save;
    $cookie_jar->add_cookie_header($request);
    my $code=$res->code;
    #print"\n $code";
    if($code==200)
    {
       
        my $content=$res->content();
	return $content;
    }
    elsif($code=~m/50/is)
    {
        
		print"\n $count Net Failure";
		$count++;
		if($count==4)
		{
			
			next;
		}
		goto netfail;
		
		
    }
    elsif($code=~m/30/is)
  {
    print "CODE::$code\n";
	my $loc=$res->header("Location");
	$loc=URI::URL->new_abs($loc,$ur);
	print "$loc\n";
	#return $loc;
    	 getcont($loc,'','','GET');
	
  }
    elsif($code=~m/40/is)
    {
        print "\n URL Not found";
    }
}
 sub getcont1()
{
    my $ur=shift;
    my $cont=shift;
    my $ref=shift;
    my $method=shift;
    my $count=0;	
	my $range = 10;
	my $minimum =70;
	my $random_number = int(rand($range)) + $minimum;
	
	print "\nSleep new:$random_number\n";
	sleep($random_number);
    netfail:
    my $request=HTTP::Request->new("$method"=>$ur);
    $request->header("Content-Type"=>"application/x-www-form-urlencoded; charset=UTF-8");
	# $request->header("Cookie"=>"PHPSESSID=jvlqqe9orhvc1ds1f97kaq29c7; srch_str=http://www.globalplanesearch.com/search?mk=776&region=Worldwide&cntry=Any&st=Any&syr=1&eyr=2020&spr=0&epr=999999999999&at=Any&ltfilt=&ut=&mf=&sort=default&shw=2000&cur=1&lsl=4&hsl=7&rs=0; srch_trm=Piper Aircraft Worldwide; __utma=55968765.71456008.1425107987.1425116125.1425122110.4; __utmc=55968765; __utmz=55968765.1425107987.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __gads=ID=d8ae6b0e21745cfd:T=1425107915:S=ALNI_MYV_zdS1zddM9SpNPrLm3PBPoL1eA; __utmb=55968765.19.10.1425122110; system=v2; gps_regis=1; __utmt=1");
     if($ref ne '')
	
    {
   
        $request->header("Referer"=>"$ref");
    }
    if(lc $method eq 'post')
    {
   
        $request->content($cont);
    }
    my $res=$ua->request($request);
    $cookie_jar->extract_cookies($res);
    $cookie_jar->save;
    $cookie_jar->add_cookie_header($request);
    my $code=$res->code;
    #print"\n $code";
    if($code==200)
    {
       
        my $content=$res->content();
	return $content;
    }
    elsif($code=~m/50/is)
    {
        
		print"\n $count Net Failure";
		$count++;
		if($count==4)
		{
			
			next;
		}
		goto netfail;
		
		
    }
    elsif($code=~m/30/is)
  {
    print "CODE::$code\n";
	my $loc=$res->header("Location");
	$loc=URI::URL->new_abs($loc,$ur);
	print "$loc\n";
	#return $loc;
    	 getcont1($loc,'','','GET');
	
  }
    elsif($code=~m/40/is)
    {
        print "\n URL Not found";
    }
}
sub trigram
{
	my $word =shift;
	my $dictword =shift;
	my @pairs = $word =~ /(?=(...))/g;
	#print(" \"@pairs\" \n");
		   local $" = q{|};
		   my $matcher = qr{(?=(@pairs))};

	#print(" \"$matcher\" \n");
	my %coef;
	my $matches = () = $dictword =~ /$matcher/g;
	my $totalz = "$matches $dictword \n";
	print "$totalz";
	my $coef = 2 * $matches / (@pairs + length($dictword)-1);
	$coef=$coef*100;
	print ("coeffesion score is $coef");
	return $coef;
}
sub ip()
{
	my $public_ip=get("http://myexternalip.com/raw");
	chomp($public_ip);
	# Get the local system's IP address that is "en route" to "the internet":
	my $config_list = `ipconfig`;
	my $local_ip;
	if($config_list=~m/IPv4[^>]*?(172[^>]*?)\s/is)
	{
		$local_ip=$1;
	}
	else
	{
		$local_ip = Net::Address::IP::Local->public;
	}
	return ($public_ip,$local_ip);
}



