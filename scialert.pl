###### Developer Name		:	Sathya T
###### Spec Name			:	Web Content Process - Download Automation Specification
###### Project Name			: 	ALM
###### Site Name			:	Scialert
###### Date					:	16-Feb-2016
###### Last Modified		:	18-Feb-2016
###### Description			:	Web Content Process - Download Automation(Pdf Download automation process)

use timestamp;
use trim;
use strict;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::URL;
use DBI;
use File::Copy;
use Cwd;
use LWP::Simple 'getstore';
use DateTime;
use Time::localtime;

#########################################  Script Start Time  #############################################
my ($Starttime,$time1)=details->datetime();

#########################################  OUTPUT FILE  #############################################
open (FH,">output.txt");
print FH "Domain_url\tUrl\tNavigated_Links\tpdf_url\tPdf_Path\tTimestamp\tTime_Difference\tPublic_ip_and_Local_ip\tSize\tPdf_Size_in_kb\tOption1\tOption2\n";
close FH;
open (FH,">output2.txt");
print FH "Domain_Name\tURL\tTotal_No_of_Pdf\tPdf_Downloaded\tScriptStartTime\tScriptEndTime\tTotalSize\n";
close FH;
######################################################################################################
my $ua=LWP::UserAgent->new();
$ua->agent("User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:36.0) Gecko/20100101 Firefox/36.0");
$ua->max_redirect(0);
my $cookie_jar = HTTP::Cookies->new(file=>$0."_cookie.txt",autosave => 1,);                    
$ua->cookie_jar($cookie_jar);
$cookie_jar->save;

# my $folder=systemdate();
my $cwd = getcwd();
my $maindir=$cwd."\/new";
mkdir($maindir);

my $count=1;
my ($public_ip,$local_ip)=details->ip();
my $no_of_pdf_count=0;
my $Sno=1;

open FH,"<input.txt";
while (my $row = <FH>) 
{
	chomp $row;
	# if()
}
print "$row\n";<>;
# open FH,"<input.txt";
# my @arr=<FH>;
# my $value;
# while(@arr)
# {

# }
# print $value;<>;

#########################################  Database Connection  ###################################
my ($database,$host,$port,$user,$pass)
open(IL,"<Database.txt");
while(<IL>)
{
	($database,$host,$port,$user,$pass)=split('\t',$_);
	$database=~s/\s+//igs;
	$host=~s/\s+//igs;
	$port=~s/\s+//igs;
	$user=~s/\s+//igs;
	$pass=~s/\s+//igs;
}	
# my $pass='P@ssw0rd@143';

my $dsn = "dbi:mysql:$database:$host:$port";
my $dbh = &sql_connect;
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do("set names utf8");

$dbh-> {'LongTruncOk'} = 1; 
$dbh-> {'LongTruncOk'} = 900000; 
####################################################################################################

my @array=("http://scialert.net/jindex.php?issn=1815-9923","http://www.scialert.net/previous.php?issn=1819-1886","http://www.scialert.net/previous.php?issn=1816-4897","http://www.scialert.net/previous.php?issn=1811-9727","http://www.scialert.net/previous.php?issn=1819-3595","http://www.scialert.net/previous.php?issn=1816-4978","http://www.scialert.net/previous.php?issn=1811-9778","http://www.scialert.net/previous.php?issn=1816-4927","http://www.scialert.net/previous.php?issn=1816-4951","http://www.scialert.net/previous.php?issn=1819-3412","http://www.scialert.net/previous.php?issn=1819-3420","http://scialert.net/previous.php?issn=1816-4935","http://scialert.net/previous.php?issn=1819-3579","http://scialert.net/previous.php?issn=1819-3587");
foreach my $url(@array)
{
	my ($strtime,$time1)=details->datetime();
	chomp($url);
	my $domain_url="http://www.scialert.net/";
	print "URL : ".$url."\n";
	my $content1=getcont($url,"","","GET");
	my $size=details->bytes($content1);
	my $url2=cond('<a\s*[^>]*?href\=\"([^>]*?)\"[^>]*?>Previous\s*Issues',$content1);
	$url2="http://www.scialert.net/".$url2;
	my $content2=getcont($url2,"","","GET");
	my $size2=$size+details->bytes($content2);
	$size=$size+details->bytes($content2);
	my ($pdf_url,$no_of_pdf_downloaded);
	$no_of_pdf_downloaded=0;
	while($content2=~m/<strong>([\d]+)\s*Volume\s*([\d]+)<\/strong>([\w\W]*?)<\/table>\s*(?:<br>)?\s*<\/td>\s*<\/tr>\s*<\/table>/igs)
	{
		my $year=trim->trim($1);
		my $volume=trim->trim($2);
		my $block=$3;
		print "year :: ".$year."\n";
		print "volume :: ".$volume."\n";
		while($block=~m/<td>\s*<font\s*color[^>]*?>\s*<a\s*[^>]*?href\=\"([^>]*?)\"[^>]*?>Issue\s*<strong>\s*([\d]+)\s*<\/strong>/igs)
		{
			my $url3="http://www.scialert.net/".trim->trim($1);
			my $issue=trim->trim($2);
			print "issue :: ".$issue."\n";
			##########Folder creation function calling######
			folder_creation($year,$volume,$issue,$maindir);
			################################################
			my $content3=getcont($url3,"","","GET");
			my $size3=$size2+details->bytes($content3);
			$size=$size+details->bytes($content3);
			while($content3=~m/(<td\s*colspan\=\"2\"\s*class\=\"bottomtext\">[\w\W]*?<td\s*width\=\"10\"\s*class\=\"normaltext\">)/igs)
			{
				my $block1=$1;
				my $url4=cond('<a\s*[^>]*?href\=\"([^>]*?)\"[^>]*?>\s*<font[^>]*?>\[Fulltext\s*PDF\]\s*<\/font>',$block1);
				$url4="http://www.scialert.net/".$url4;
				print "Pdf Link Taken : ".$url4."\n";
				my $pdf_value=cond('http\:\/\/(?:www\.)?scialert\.net\/qredirect\.php\?doi\=([^>]*?)\&linkid\=pdf',$url4);
				$pdf_value=~s/([^>]*?).([\d]+).([\d]+).([\d]+)/$1\/$2\/$3\-$4/igs;
				my $filename=cond('<td colspan="2"[^>]*?><font[^>]*?>[^>]*?([\d]+\-[\d]+)\,',$block1);
				my $nav_url=$url."<>".$url2."<>".$url3."<>".$url4;
				if($url4 ne "")
				{
					$no_of_pdf_count++;
				}
				########Folder creation function calling-For removing Duplicate values to insert into a database########
				my $status=check($url4);
				########################################################################################################
				my $pdf_url="http://docsdrive.com/pdfs/academicjournals/".$pdf_value."\.pdf";
				print "Pdf : ".$pdf_url."\n";
				if($status eq 'unique')
				{
					my $directory=$maindir."/V$volume\_I$issue\_$year";					
					$filename=$filename."\.pdf";
					########################GETSTORE to download a file##########################
					my $file=getstore($pdf_url,$filename);
					#############################################################################
					########################Pdf File size in kb##################################
					my $file1=$cwd."/".$filename;
					my $filesize = -s $file1;
					my $filesize_kb=$filesize / 1024;
					#############################################################################
					move("$cwd/$filename", "$directory/$filename") or die "The move operation failed: $!";
					$no_of_pdf_downloaded++;
					my $pdf_path="$directory/$filename";
					print "file size in KB::$filesize_kb\n";
					print "------------------pdf download :: ".$no_of_pdf_downloaded."----------------------\n";
					my ($endtime,$time2)=details->datetime();
					my $difftime=details->time_difference($time1,$time2);	
					open (FH,">>output.txt");
					print FH "$domain_url\t$url\t$nav_url\t$pdf_url\t$pdf_path\t$endtime\t$difftime\t$public_ip-$local_ip\t$size3\t$filesize_kb\n";
					close FH;
					my $query1="insert into table1 (Domain_url,Url,Navigated_Links,pdf_url,Pdf_Path,Timestamp,Time_Difference,Public_ip_and_Local_ip,Size)values(\'$domain_url\',\'$url\',\'$nav_url\',\'$pdf_url\',\'$pdf_path\',\'$endtime\',\'$difftime\',\'$public_ip\-$local_ip\',\'$size3\')";
					&Query_Exceute($query1);
				}
			}
			print "**************No of PDF Count  ::  ".$no_of_pdf_count."******************\n";<>;
			
			my ($finishtime,$time1)=details->datetime();
			open (FH,">output2.txt");
			print FH "$domain_url\t$url\t$no_of_pdf_count\t$no_of_pdf_downloaded\t$Starttime\t$finishtime\t$size\n";
			close FH;
		}
		print "**************Group 8 URL :: ".$count." Completed******************\n";<>;
	}
	my ($finishtime,$time1)=details->datetime();
	my $query1="insert into table2 (Domain_url,Url,Total_PDF_Count,Pdf_Downloaded,ScriptStartTime,ScriptEndTime,TotalSize)values(\'$domain_url\',\'$url\',\'$no_of_pdf_count\',\'$no_of_pdf_downloaded\',\'$Starttime\',\'$finishtime\',\'$size\')";
	&Query_Exceute($query1);
}
print "**************Process Completed******************\n";

sub check()
{
	my $status;
	my $pdf_url=shift;
	my $Query="select *from table1 where pdf_url like '%".$pdf_url."%'";
	my $Input_Crawler_Ins_sth=Query_Exceute($Query);
	my @Output_result = $Input_Crawler_Ins_sth->fetchrow();
	my $output_id = $Output_result[0];
	print "\n**Que:$output_id**\n";
	if(length($output_id)>=1)
	{
		$status="duplicate";
	}
	else
	{
		$status="unique";
	}
	print "\nStatus:$status\n";
	
	return $status;
}


sub cond()
{
	my $regex=shift;
	my $content=shift;
	if($content=~m/$regex/is)
	{
		my $value=trim->trim($1);
		return $value;
	}
}
sub folder_creation()
{
	my $year=shift;
	my $volume=shift;
	my $issue=shift;
	my $main_dir=shift;
	
	my $folder="V$volume\_I$issue\_$year";
	my $dir="$main_dir/".$folder;
	if (-e $dir and -d $dir) 
	{
		print "Directory exists\n";
	}
	else 
	{
		print "Directory doesnot exists\n";
		mkdir( $dir ) or die "Couldn't create $dir directory, $!\n";
		print "Directory created successfully\n";
	}
}
sub getcont()
{
    my $ur=shift;
    my $cont=shift;
    my $ref=shift;
    my $method=shift;
    my $count=0;	
	# sleep(int(rand(15)));
	# sleep(15);
	if($ur ne "")
	{
		netfail:
		my $request=HTTP::Request->new("$method"=>$ur);
		$request->header("Content-Type"=>"application/x-www-form-urlencoded");

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
			# $content=decode_entities($content);
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
}
sub sql_connect
{
	my $main=shift;
	Reconnect:
	my $dbh = DBI->connect($dsn, $user, $pass,{AutoCommit => 1}) or warn "$DBI::errstr\a\a\n";
	
	if(defined $dbh)
	{
		print "Data base Connected successfully\n";
	}
	else
	{
		print "Please Check Ur Database\n";
		sleep(10);
		goto Reconnect;
	}
	return $dbh;
}


#********************* Sql Execute function ********************#
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
			if(my $dbh1=DBI->connect($dsn,"$user","$pass",{AutoCommit=>1}))
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

############################SQL Return######################################
sub sql_return
{
	my $main=shift;
	my $query=shift;
	my $data;
	QUERY_Ping:
	$dbh->do("set character set utf8");
	$dbh->do("set names utf8");
	if(defined $dbh)
	{
		my @row2;
		eval
		{
			$data=$dbh->prepare($query);
		};
		if($@)
		{
			my $err = $@;
		}
		eval
		{
			$data->execute();
		};
		if($@)
		{

			my $err = $@;
		}
		while(my $row = $data->fetchrow_arrayref)

		{
				push(@row2,[@$row]);
		}
		$data->finish();
		return(\@row2);
	}
	else
	{
		my $Err_var=$dbh->errstr;
		if($Err_var=~m/syntax/is)
		{
			open(FH2,">>$0"."_Error.txt");
			print FH2 "$query\;\n";
			close FH2;        
			return;
		}
		else
		{
			open(FH2,">>$0"."_Error.txt");
			print FH2 "$query\;\n";
			close FH2;               
			DB_Ping:
			if(my $dbh1 = DBI->connect($dsn, "$user", "$pass",{AutoCommit => 1}))
			{
				$dbh1->do("set names utf8");
				$dbh1-> {'LongTruncOk'} = 1;
				$dbh1-> {'LongReadLen'} = 90000;                
				$dbh=$dbh1;        
				goto QUERY_Ping;
			}
			else
			{
				print "\nDB FAILURE";
				goto DB_Ping;
			}
		}    
	}
}
sub systemdate()
{
	# my $date;
	# my $tm=localtime;
	# my ($day,$month,$year)=($tm->mday,$tm->mon,$tm->year);
	# print "\n$year\n";
	# $year=1900+$year;
	# print "\n$year\n";
	# $date="$day-$month-$year";
	my $dt=DateTime->today;
	my $date=$dt->date;
	# print "\n$date\n";
	return $date;
}