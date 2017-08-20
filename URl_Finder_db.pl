
##########################################################
#Name		:	Sugumar.P
#Date		:	25-April-2015

##########################################################

#Aim			:	Finding the correct url for the company name using 3rd parties(yelp,localgoogle,localyahoo,switchboard) and google process
#Program Name	:	integration.pl
#Modified Date	:	19-01-2011 ( 1. Changing the 3rd party priority
#						 2. Add the comment and confirmed  url variable to give the absolute comment	
#						 3. Included if unable to confirm, then compare local google with yelp website if both have websites
#Modified Date	:	22-01-2011 ( 1. Included the condition-> name token score <50 but address or phone is confirmed
#						 2. Included if unable to confirm, then compare local google or yelp with i/p website if any one 3rd party have website
# 						 3. get_content() -> use refresh count(2 times) for avoiding the continuous looping
#						 4. If website is found as domain squatting, instead of just exit from the flow, confirmation process should be done.
#Modified Date	:	24-01-2011 ( 1. Included the proxy changing if yelp is blocked
#Modified Date	:	23-02-2011 ( 1. Included the changes in splitting bigram characters and calculating the bigram score(
#											  If bigram score for url and name  then 1st array should be url bigram characters,
#											 2nd array should be name bigram characters.
#Modified Date	:	01-03-2011 ( 1. Change the seperating phone token function and include the phone token score withsource function for
#											confirming the phone no in the source			
##########################################################
#URL VALIDATION FLAG=0 ->  Initial
#URL VALIDATION FLAG=1 ->  Invalid URL (third party, not working )
#URL VALIDATION FLAG=2 ->  Unable to confirm the url
#URL VALIDATION FLAG=3 ->  Valid by phone
#URL VALIDATION FLAG=4 ->  Valid by address
#URL VALIDATION FLAG=5 ->  Valid by Comparing 3rd party-local google and yelp websites
##########################################################
use URL_Finder_US_Module_V5;
use strict;
use DBI;

my $object=URL_Finder_US_Module_V5->new;

#### Log file for timing
open(gh,">>log.txt");
print gh "Start Time - ".localtime()."\n";
close(gh);

### Third party urls

#DATABASE CONNECTION
# my $databaseserver  = '50.22.144.234';
# my $databasename='ATTI';
# my $user='attiuser';
# my $pass='Mobius@atti!@#';
# my $port='1433';

#DATABASE CONNECTION
my $server='SCK-SYS-953\SQLEXPRESS';
my $dbname="Crawling";
my $username="sa";
my $password='sa@123';
my $dsn = "dbi:ODBC:DRIVER={SQL Server};SERVER={$server};Database=$dbname";
my $dbh=DBI->connect($dsn,"$username","$password",{AutoCommit=>1});
=e
my $databaseserver  = 'SCK-SYS-694';	my $databasename='Perl';
my $user='sa';	my $pass='sa@123';	my $port='8080';
my $dsn = "driver={SQL Server};Server=$databaseserver,$port;database=$databasename;";
my $dbh = DBI->connect("dbi:ODBC:$dsn","$user","$pass") or die "\n$DBI::errstr\n";
my $dbh1 = DBI->connect("dbi:ODBC:$dsn","$user","$pass") or die "\n$DBI::errstr\n";
my $dbh2 = DBI->connect("dbi:ODBC:$dsn","$user","$pass") or die "\n$DBI::errstr\n";
=cut
$dbh-> {'LongTruncOk'} = 1;$dbh-> {'LongReadLen'} = 90000;

chomp( my $sno_starting = $ARGV[0] );chomp( my $sno_ending = $ARGV[1] );
die "\n\nENTER COMMAND LINE INPUT CORRECTLY(StartSNO,EndSNO)....\n\n" unless( $sno_ending );

my $query = "select * from Url_finder_Sample_Input where S_No >= $sno_starting and S_No  <= $sno_ending";
my $sth = $dbh->prepare( $query );
$sth->execute();
my $count=1;
my @sno; my @Duns; my @Record_id; my @Listing_Name; my @Address; my @City; my @State; my @zip; my @Phone; my @URL; 
while(my @results = $sth->fetchrow_array)
{	
	my $sno=$results[0];
	my $Duns=$results[0];
	my $Record_id=$results[0];
	my $Record_id="";
	# my $Directory=$results[3];
	my $Listing_Name=$results[1];
	my $Address=$results[2];
	my $Address1=$results[4];
	my $City=$results[5];
	my $State=$results[6];
	my $zip=$results[7];
	my $Phone=$results[10];
		
	push(@sno,$sno);
	push(@Duns,$Duns);
	push(@Record_id,$Record_id);
	push(@Listing_Name,$Listing_Name);
	push(@Address,$Address);
	push(@City,$City);
	push(@State,$State);
	push(@zip,$zip);
	push(@Phone,$Phone);
	
}

for(my $i=0;$i<=$#sno;$i++)
{
	my $sno=$sno[$i];
	my $Duns=$Duns[$i];
	my $Record_id=$Record_id[$i];
	my $Listing_Name=$Listing_Name[$i];
	my $Address=$Address[$i];
	my $City=$City[$i];
	my $State=$State[$i];
	my $zip=$zip[$i];
	my $Phone=$Phone[$i];
	# my $Record_id="";
	my $URL="";
	
	my $Geo=$City.",".$State;
	
	print "######################################\n";
	print "$count) SNO=$sno)$Record_id-$Listing_Name\n";
	print "######################################\n";
	
	open(ff,">>processed_sno.txt");
	print ff "SNO=$sno\n";
	close(ff);
	
	my($thirdparty_status,$working_status,$status_squatting,$flash,$url_name_score,$url_validation_flag,$url_validation_status,$token_name_score,$token_phone_score,$token_address_score,$token_city_score,$token_state_score,$whole_link,$predefined_link,$resulted_link);
	my($processing,$comment,$confirmed_url);
	
	my $Input_Name="$Listing_Name";
	$Listing_Name=~s/\(.*\)//igs;
	$Listing_Name=~s/\s\s+/ /igs;
	$Listing_Name=~s/^\s*|\s*$//igs;
	
	my $company="$Listing_Name";
	$company=~s/\s/\+/igs;
	$company=~s/\&/\%26/igs;
	$company=~s/\'/\%27/igs;
	$company=~s/\@/\%40/igs;
	my $geo="$Geo";
	$geo=~s/\s/\+/igs;
	$geo=~s/\,/\%2C/igs;
	print "######### input token #########\n";
	#### Seperating the input name as token and store into an array
	my $company1="$Listing_Name";
	my $company1=$object->company_cleanup($company1);
	my $sep_token=$object->seperating_token($company1);
	my @ip_name_token=@$sep_token;
	print "input name token=@ip_name_token\n";
	####
	#### Seperating the input address as token and store into an array
	my $address2=lc ($object->clean_text("$Address"));
	my $sep_token=$object->seperating_token($address2);
	my @ip_address_token=@$sep_token;
	print "input address token=@ip_address_token\n";
	my($website,$status,$comp_rate,$name_bi,$phone_rate,$addr_rate,$city_rate,$state_rate,$detail_url);
	my($input_website,$yelp_website,$localyahoo_website,$localgoog_website,$switch_website,$yellowpages_superpages_website,$manta_website);
	$input_website="$URL";
	$website="$URL";

	### Capturing website in Google search
	my($highest_score,$Freeze_URL);
	
		print "\n-------------------------------Capturing the website in google search\n";
		$processing="Capturing Website in GOOGLE";
		my $Listing_Name1=$Listing_Name;
		my $Listing_Name1=$object->company_cleanup($Listing_Name1);
		$Listing_Name1=~s/\s\s+/ /igs;
		$Listing_Name1=~s/^\s+|\s+$//igs;
		my $search_term=$Listing_Name1;
		my $google_url="http://www.google.com/search?hl=en&client=firefox-a&hs=FeT&rls=org.mozilla%3Aen-US%3Aofficial&q=$search_term&btnG=Search&aq=f&aqi=&aql=&oq=&gs_rfai=";
		my $cont=$object->Get_Content($google_url);
		($highest_score,$Freeze_URL)=$object->google_search($cont,$Listing_Name1);
		my $Google_Website="$Freeze_URL";
		my $new_website="$Freeze_URL";
		print "\n\n..Freeze_URL: $Freeze_URL";
		### comparing the (input website with google website) and (local google website with google website) and (yelp website with google website) and (switchboard website with google website) and (local yahoo website with google website)
		my $cmp_value1=$object->comparing_2_website($input_website,$Google_Website);
		print "Input and Google websites are equal\n" if($cmp_value1==1);
		### Confirming the GOOGLE website
		if(($new_website ne '') && ($cmp_value1==0) )# && ($cmp_value5==0))
		{
			my $input_url=$new_website;
			$processing="Confirming the Google website";
			print "\n-------------------------------Confirming the Google search website\n";
			($thirdparty_status,$working_status,$status_squatting,$flash,$url_name_score,$url_validation_flag,$url_validation_status,$token_name_score,$token_phone_score,$token_address_score,$token_city_score,$token_state_score,$whole_link,$predefined_link,$resulted_link)=$object->website_confirmation($input_url,$Listing_Name,$Phone,$Address,$City,$State);
		
			my $site_name="Google";
			### For updating the comment field check ( the url validation flag and name token score)
			($comment,$confirmed_url)=comment($site_name,$url_validation_flag,$token_name_score,$input_url,$thirdparty_status,$working_status,$status_squatting);
		}
	}
	# my $Freeze_URL_bing;
	# my $goog_site="$localgoog_website";
	# my $yahoo_site="$localyahoo_website";
	# my $yellowpages_site="$yellowpages_superpages_website";
	# my $manta_website="$manta_website";
	# my $google_site="$Freeze_URL";
	# my $bing_site="$Freeze_URL_bing";
	
	# my %website_hash;
	# my $third_value=$object->third_party_checking($goog_site,@third_party);
	# $goog_site=$object->website_cleaning($goog_site) if($third_value!=1);
	# my $third_value=$object->third_party_checking($google_site,@third_party);
	# $google_site=$object->website_cleaning($google_site) if($third_value!=1);
	# my $third_value=$object->third_party_checking($bing_site,@third_party);
	# $bing_site=$object->website_cleaning($bing_site) if($third_value!=1);
	
	# $website_hash{$goog_site}='' if($goog_site);
	# $website_hash{$yahoo_site}='' if($yahoo_site);
	# $website_hash{$yellowpages_site}='' if($yellowpages_site);
	# $website_hash{$manta_website}='' if($manta_website);
	# $website_hash{$google_site}='' if($google_site);
	# $website_hash{$bing_site}='' if($bing_site);
	
	
	my $sitein_detail_url;
	### if the status is UNABLE TO CONFIRM THE URL, ### Capturing the website by site colon for store locator - using address
	
	### Formatting the Confirmed url
	if($confirmed_url ne '')
	{
		$confirmed_url=~s/^http\:\/\///igs;
		$confirmed_url=~s/^www\.//igs;
		$confirmed_url=~s/^www\d+\.//igs;
		$confirmed_url="http://www.".$confirmed_url if($confirmed_url!~m/^http(?:s)?\:\/\/www\./is);
		$confirmed_url=~s/^((http\:\/\/)?www\..*?)\/.*?$/$1/igs;
	}
	###
	### Substituting ' with '' for database 
	$Address=~s/\'/\'\'/igs;$City=~s/\'/\'\'/igs;$State=~s/\'/\'\'/igs;$Phone=~s/\'/\'\'/igs;$input_website=~s/\'/\'\'/igs;$Input_Name=~s/\'/\'\'/igs;$thirdparty_status=~s/\'/\'\'/igs;$working_status=~s/\'/\'\'/igs;$status_squatting=~s/\'/\'\'/igs;$flash=~s/\'/\'\'/igs;
	$url_name_score=~s/\'/\'\'/igs;$token_name_score=~s/\'/\'\'/igs;$token_phone_score=~s/\'/\'\'/igs;$token_address_score=~s/\'/\'\'/igs;$token_city_score=~s/\'/\'\'/igs;
	$token_state_score=~s/\'/\'\'/igs;$whole_link=~s/\'/\'\'/igs;$predefined_link=~s/\'/\'\'/igs;$resulted_link=~s/\'/\'\'/igs;$comp_rate=~s/\'/\'\'/igs;
	$name_bi=~s/\'/\'\'/igs;$phone_rate=~s/\'/\'\'/igs;$addr_rate=~s/\'/\'\'/igs;$city_rate=~s/\'/\'\'/igs;$state_rate=~s/\'/\'\'/igs;
	$localgoog_website=~s/\'/\'\'/igs;$Freeze_URL_bing=~s/\'/\'\'/igs;$yelp_website=~s/\'/\'\'/igs;$switch_website=~s/\'/\'\'/igs;$localyahoo_website=~s/\'/\'\'/igs;$highest_score=~s/\'/\'\'/igs;
	$Freeze_URL=~s/\'/\'\'/igs;$url_validation_status=~s/\'/\'\'/igs;$processing=~s/\'/\'\'/igs;$comment=~s/\'/\'\'/igs;$confirmed_url=~s/\'/\'\'/igs;$sitein_detail_url=~s/\'/\'\'/igs;
	$sno=~s/\s*\.0//igs;
	
	###
	print "query=$sno,$Duns,$Record_id,$Input_Name,$Address,$City,$State,$Phone,$input_website,$thirdparty_status,$working_status,$status_squatting,$flash,$url_name_score,$token_name_score,$token_phone_score,$token_address_score,$token_city_score,$token_state_score,$whole_link,$predefined_link,$resulted_link,$comp_rate,$name_bi,$phone_rate,$addr_rate,$city_rate,$state_rate,$localgoog_website,$Freeze_URL_bing,$yelp_website,$switch_website,$localyahoo_website,$highest_score,$Freeze_URL,$url_validation_status,$processing,$comment,$confirmed_url,$sitein_detail_url\n";<>;
	# my $project_inp_que1="insert into URLFinderOutput_google values ('$sno','$Duns','$Input_Name','$Address','$City','$State','$Phone','$input_website','$thirdparty_status','$working_status','$status_squatting','$flash','$url_name_score','$token_name_score','$token_phone_score','$token_address_score','$token_city_score','$token_state_score','$whole_link','$predefined_link','$resulted_link','$comp_rate','$name_bi','$phone_rate','$addr_rate','$city_rate','$state_rate','$localgoog_website','$Freeze_URL_bing','$yelp_website','$switch_website','$localyahoo_website','$highest_score','$Freeze_URL','$url_validation_status','$processing','$comment','$confirmed_url','$sitein_detail_url')";
		# open fh,">>Query_log.txt";
        # print fh "insert into URLFinderOutput_google values ('$sno','$Duns','$Input_Name','$Address','$City','$State','$Phone','$input_website','$thirdparty_status','$working_status','$status_squatting','$flash','$url_name_score','$token_name_score','$token_phone_score','$token_address_score','$token_city_score','$token_state_score','$whole_link','$predefined_link','$resulted_link','$comp_rate','$name_bi','$phone_rate','$addr_rate','$city_rate','$state_rate','$localgoog_website','$Freeze_URL_bing','$yelp_website','$switch_website','$localyahoo_website','$highest_score','$Freeze_URL','$url_validation_status','$processing','$comment','$confirmed_url','$sitein_detail_url')\n";
        # close fh;
	 # my $Input_Crawler_Ins_sth1=Query_Exceute($project_inp_que1);
	$count++;
}

### Function for printing the comment field and confirmed url field
sub comment
{
	my ($site_name,$url_validation_flag,$token_name_score,$input_url,$thirdparty_status,$working_status,$status_squatting)=@_;
	my ($comment,$confirmed_url);
	
	if($url_validation_flag==3)
	{
		if($token_name_score<50)
		{
			$comment="Valid URL by Phone-$site_name and name <50";
			$confirmed_url=$input_url;
		}
		else
		{
			$comment="Valid URL by Phone-$site_name";
			$confirmed_url=$input_url;
		}	
	}
	if($url_validation_flag==4)
	{
		if($token_name_score<50)
		{
			$comment="Valid URL by Address-$site_name and name <50";
			$confirmed_url=$input_url;
		}
		else
		{
			$comment="Valid URL by Address-$site_name";
			$confirmed_url=$input_url;
		}	
	}
	if($url_validation_flag==1)
	{
		$comment="Invalid URL-$thirdparty_status $working_status $status_squatting";
		$confirmed_url=$input_url if $input_url;
	}
	return($comment,$confirmed_url);
}	

#### Log file for timing
open(gh,">>log.txt");
print gh "End Time - ".localtime()."\n";
close(gh);	
sub Query_Exceute
{
	my $query=shift;           
	
	QUERY_Ping:
	my $sth1=$dbh->prepare($query);       
	
	if($sth1->execute())
	{
		return($sth1); 
	}
	else
	{
		my $err=$DBI::errstr;
		
		if($err=~m/duplicate/is)
		{
			print "\n\nDuplicate\n";
			return;
		}
		elsif($err=~m/syntax|truncate/is)
		{
			print "syntax error\n";
			open(FH,">>Film_Log_File.txt");
			print FH "\n$query";
			close FH;
			
		}
		elsif($err=~m/insert\s*statement/is)
		{
			open(FH,">>Film_Log_File.txt");
			print FH "\n$query";
			close FH;
			
		}
		else
		{                   
			DB_Ping:			
			if(my $dbh1=DBI->connect($dsn,"$username","$password",{AutoCommit=>1}))
			{
				$dbh1-> {'LongTruncOk'} = 1;
				$dbh1-> {'LongReadLen'} = 90000;                            
				
				$dbh=$dbh1;     
				goto QUERY_Ping;
			}
			else
			{
				print "\nDB FAILURE";
				sleep(10);
				
			}
		}              
	}
	$sth1->finish;
}