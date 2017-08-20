#J.kavi sudha
#Email_domail:collecting emails

use strict;
# use warnings;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::URL;
use HTML::Entities;
use Digest::MD5;
use DBI;
use List::MoreUtils qw/uniq/;
use LWP::Simple;

my $cookie_jar= HTTP::Cookies->new(file=>$0."_cookie.txt",autosave => 1,);
my $ua=LWP::UserAgent->new;
$ua->agent("User-Agent:Mozilla/5.0 (Windows NT 6.1; rv:43.0) Gecko/20100101 Firefox/43.0");

my $code="500";


open FH,">Email_output_all.txt";
print FH "SORT_NO\tDOMAIN\tNAME\tLINK\tCONTACT LINK\tVALID EMAIL\tTEST EMAIL\tCONTENT STATUS\n";
close FH;
# open FH,">Email_output1.txt";
# print FH "SORT_NO\tDOMAIN\tNAME\tLINK\tEMAIL\tCONTENT STATUS\n";
# close FH;

my $count=0;
#input file
open (FA,"input.txt");

while(<FA>)
{
	
	my ($sort_sn,$domain,$name,$url)=split('\t',$_);
	$url=~s/\s+/ /igs;
	my $url1=$url;
	$url1=~s/\&/%26/igs;
	
	my $link=$url1;
	print "$link\n";
	
	my ($con,$code1)=&getcont("$link","","","GET");
	open FH,">$sort_sn.content1.html";
	print FH "$con\n";
	close FH;
	
	if($con eq "")
	{
		open FH,">>Email_output_all.txt";
		print FH "$sort_sn\t$domain\t$name\t$link\t\t\t\tNot getting content\n";
		close FH;
	}
	else
	{
	
		my($link_contact);
		if($link=~m/\/$/is)
		{
			$link_contact=$link."contact";
		}
		else
		{
			$link_contact=$link."/contact";
		}
		
		$link_contact=~s/\/\s+\//\//igs;	
		print "$link_contact\n";
		my ($con_contact,$code2)=&getcont("$link_contact","","","GET");
		open FH,">$sort_sn.content.html";
		print FH "$con\n";
		close FH;
		
		my $em=Email($con);
		print "$em\n";
		
		my $em_contact=Email($con_contact);	
		# print "email:$em_contact\n";
		my $finalEmail= $em.",".$em_contact;
		my($ValidEmail,$testemail);
		my $uni;
		$finalEmail=~s/\s+/ /igs;
		$ValidEmail=~s/\s+/ /igs;
		
		my @Emaillarray = split(/\,/,$finalEmail);
		my @uni_Eamil = uniq @Emaillarray;
		foreach $testemail (@uni_Eamil)
		{
			#print "\n$testemail\n";
			$uni=$uni.",".$testemail;
			my $score=Bigram($name,$testemail);
			if($score>=2)
			{
				$ValidEmail=$ValidEmail.",".$testemail;
			}
				
		}
		# open FH,">>Email_output1.txt";
		# print FH "$sort_sn\t$domain\t$name\t$link\t\t$ValidEmail\t\n";
		# close FH;
		$uni=~s/\,$//igs;
		$uni=~s/^\,//igs;
		$ValidEmail=~s/\,$//igs;
		$ValidEmail=~s/^\,//igs;
		open FH,">>Email_output_all.txt";
		print FH "$sort_sn\t$domain\t$name\t$link\t$link_contact\t$ValidEmail\t$uni\t\n";
		close FH;
		
		$count++;
		print "count::::::::::::::::::::::::::::::::::::::::::::$count\n";
	}	
	
	
}


sub Bigram
{
	my $word =shift;
	my $dictword =shift;
	$dictword=~s/\s+//igs;
	$word=~s/\s+//igs;
	my @pairs = $word =~ /(?=(...))/g;
	#print(" \"@pairs\" \n");
	local $" = q{|};
	my $matcher = qr{(?=(@pairs))};
	#print(" \"$matcher\" \n");
	my %coef;
	my $matches = () = $dictword =~ /$matcher/g;
	my $totalz = "$matches $dictword \n";
	#print $totalz;
	my $coef = 2 * $matches / (@pairs + length($dictword)-1);
	$coef=$coef*100;
	print ("coeffesion score is $coef");
	return $coef;
	
}


sub Email()
{
	my $Source_page=shift;
	my $Email;
	while($Source_page=~m/([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4})/igs)
	{
		my $E=$1;
		# print "EEEEEEEEEEEEEEEEEEE:$E\n";
		# Win32::MsgBox("$E");
		# $Email=$Email.",".$E;
		$Email=$Email.",".$E;
		
	
		
	}
	$Email=~s/\,\s*\,\s*\,\s*/\,/igs;
	$Email=~s/\,\s*\,\s*/\,/igs;
	$Email=~s/\,$//igs;
	$Email=~s/^\,//igs;
	return $Email;
}
	
sub getcont()
{
    my $ur=shift;
    my $cont=shift;
    my $ref=shift;
    my $method=shift;
    my $count=0;	
	#sleep(int(rand(25)));
	# sleep(15);
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
		return ($content,$code);
    }
    elsif($code=~m/50/is)
    {
		my $content;
		print"\n $count Net Failure";
		$count++;
		return ($content,$code);
    }
    elsif($code=~m/30/is)
	{
		print "CODE::$code\n";
		my $loc=$res->header("Location");
		$loc=URI::URL->new_abs($loc,$ur);
		print "$loc\n";
		# return $loc;
    	&getcont($loc,'','','GET');
	}
    elsif($code=~m/40/is)
    {
		my $content=$res->content();
		return ($content,$code);
    }
}
sub trim()
{
	my $string=shift;
	
	$string=~s/<style[^>]*?>[^>]*?<\/style>//igs;
	# $string=~s/<script[^>]*?>//igs;
	
	$string=~s/<[^>]*?>/ /igs;
	# $string=~s/\s+/ /igs;
	# $string=~s/^\s+//igs;
	# $string=~s/\s+$//igs;
	
	return $string ;
}
	
	
	
	