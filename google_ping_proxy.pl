

##########CREATED DATE: APR-8-2016##############
##########Developer: V.U.Balasubramaniyan############
use strict;
use HTTP::Cookies;
use HTML::Entities;
use URI::URL;
use LWP::Simple;
# use warnings;
use Time::Piece;
use LWP::UserAgent;
use Encode;
use Net::Address::IP::Local;
use trim;
my $cookie_jar= HTTP::Cookies->new(file=>$0."_cookie.txt",autosave => 1,);
my $ua1=LWP::UserAgent->new;
my $ua2=LWP::UserAgent->new;
$ua1->agent("User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0");
$ua1->cookie_jar($cookie_jar);

$ua2->agent("User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:36.0) Gecko/20100101 Firefox/36.0");
$ua2->cookie_jar($cookie_jar);
open(DH,">output.txt"); 
print DH "website\n";
close (DH);
my $Count2=0;
my $code="500";
open(SH,"<company.txt");
my @arr=<SH>;
foreach my $key(@arr)
{
  chomp($key);
  my ($website,$ip)=google($key); 
  open(DH,">>output.txt"); 
  print DH "$website\t$ip\n";
  close (DH); 
print "stop\n";


}

sub google()
{
   my $string=shift;
      $string=entities($string);
   my $search_link="https://www.google.co.in/search?q=$string"; 
   my ($search_link_con,$ip)=getcont1("$search_link","","","GET"); 
   open FC,">content.html";
   print FC "$search_link_con\n";
   close FC;
   my $website;
   my $counting=1;   
   while($search_link_con=~m/<cite>([\w\W]*?)<\/cite>/igs)
   {
	#----------------->collecting first link domain:
	my $link_collection=$1;
	 print "before_link_collection:$link_collection\n";
	   $link_collection=trim($link_collection);
	   chop($link_collection);
     print "After link collection:$link_collection\n";  
	   my $flag="false";   
   	   if($link_collection=~m/\//is) 
       {
	     $website="";
	     $flag="false"; 
	   } 
       elsif($link_collection=~m/([^>]*)/is)
       {
	      $website=$1;
	      $flag="true";  
	   }
       if($flag eq 'true')
       {
	     goto next1;
	   }
      print "count:$counting\n";
	  $counting++;  	   
   } 
   next1:     
	 return($website,$ip);
}

sub trim()
{
	my $string=shift;
	$string=~s/<[^>]*?>//igs;
	$string=~s/\s+/ /igs;
	$string=~s/^\s+//igs;
	$string=~s/\s+$//igs;
	$string=~s/\s+/ /igs;
	return $string ;
}
sub entities()
{
	my $search_string=shift;
	$search_string=~s/\&/%26/igs;
	$search_string=~s/\s+/\+/igs;
	$search_string=~s/\"/%22/igs;
	$search_string=~s/\@/%40/igs;
	return $search_string;
}
=e
sub getcont()
{
    my($ur,$cont,$ref,$method)=@_;
	# print "url getcontent:::$ur\n";
    netfail:
    my $request=HTTP::Request->new("$method"=>$ur);
    $request->header("Content-Type"=>"text/html");
    # $request->header("Cookie"=>'lidc="b=TGST00:g=64:u=1:i=1459774876:t=1459861276:s=AQE1QfklW2N96zxm_bHz-hr9PX-yywVB');
    if($ref ne '')
    {
   
        $request->header("Referer"=>"$ref");
    }
    if(lc $method eq 'post')
    {
   
        $request->content($cont);
    }
	my $range = 10;
	my $minimum =70;
	my $random_number = int(rand($range)) + $minimum;
	
    print "\nSleep new:$random_number\n";
	 # sleep($random_number);
	my $res=$ua->request($request);
    $cookie_jar->extract_cookies($res);
    $cookie_jar->save;
    $cookie_jar->add_cookie_header($request);
    my $code=$res->code;
    print"\n $code";
	
    if($code==200)
    {
       
        my $content=$res->content();
		$content=decode_entities($content);
        return $content;
    }
    elsif($code=~m/50/is)
    {
        print"\n Net Failure";
        # sleep(30);
        goto netfail;
    }
    elsif($code=~m/30/is)
    {
       
       my $loc=$res->header("Location");
         print "\nLocation: $loc";
        my $request1=HTTP::Request->new(GET=>$loc);
        $request1->header("Content-Type"=>"application/x-www-form-urlencoded");
        my $res1=$ua->request($request1);
        $cookie_jar->extract_cookies($res1);
        $cookie_jar->save;
        $cookie_jar->add_cookie_header($request1);
        my $content1=$res1->content();
        return $content1;

    }
    elsif($code=~m/40/is)
    {
		 my $content=$res->content();
		#$content=decode_entities($content);
        return $content;
        print "\n URL Not found";
    }
}
=cut
sub getcont1()
{
    my($ur,$cont,$ref,$method)=@_;
    netfail:
	our ($ip);
    my $request=HTTP::Request->new("$method"=>$ur);
    $request->header("Content-Type"=>"application/x-www-form-urlencoded");
	if($code=~m/50/is)
	{
		($ip)=getproxy();
		$ip=~s/\s+//igs;
		$ua1->proxy('http', $ip);
		print "\nIP Address:$ip\n";
	}
	else
	{
		$Count2++;
		if($Count2>=100)
		{
			$Count2=0;
			$code=500;
			goto netfail;
		}
	}
    #$request->header("Cookie"=>"__utma=32463673.2123661471.1427974268.1427974268.1427974268.1; __utmb=32463673.2.10.1427974268; __utmc=32463673; __utmz=32463673.1427974268.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmt=1; __unam=84a5df6-14c79e62910-189a876c-2");
    if($ref ne '')
    {
   
        $request->header("Referer"=>"$ref");
    }
    if(lc $method eq 'post')
    {
   
        $request->content($cont);
    }
    my $res=$ua1->request($request);
    $cookie_jar->extract_cookies($res);
    $cookie_jar->save;
    $cookie_jar->add_cookie_header($request);
    my $code=$res->code;
    print"$code\n";
    if($code==200)
    {
       
        my $content=$res->content();
		$content=decode_entities($content);
        return ($content,$ip);
    }
    elsif($code=~m/50/is)
    {
        print"Net Failure\n";
        # sleep(30);
        goto netfail;
    }
    elsif($code=~m/30/is)
    {
       
		my $loc=$res->header("Location");
        print "Location: $loc\n";
        my $request1=HTTP::Request->new(GET=>$loc);
        $request1->header("Content-Type"=>"application/x-www-form-urlencoded");
        my $res1=$ua1->request($request1);
        $cookie_jar->extract_cookies($res1);
        $cookie_jar->save;
        $cookie_jar->add_cookie_header($request1);
        my $content1=$res1->content();
        return ($content1,$ip);

    }
    elsif($code=~m/40/is)
    {
		my $content=$res->content();
		# $content=decode_entities($content);
        return ($content,$ip);
        print "URL Not found\n";
    }
}

sub getproxy()
{
	g:
	my ($port);
	# print "\nFile read\n";
	# open FILE, "C:\\Proxy\\port_list.txt";
	# rand($.)<1 and ($port=$_) while <FILE>;
	# close FILE;
	# print "\nnew PORT is :$port\n";
	my $cgi_url="http://172.16.23.3/cgi-bin/proxy/proxytest.cgi";
	print "\nCollecting Proxy From Server 3.............\n";
	my ($contee)=getcont2($cgi_url,"","","GET");
	open FS,">cgi_url.html";
	print FS "$contee\n";
	close FS;
	if($contee=~m/<table>\s*<tr>\s*<td>(ht[^>]*?)<\/td>\s*<\/tr>\s*<\/table>/is)
	{
		$port=$1;
		print "$port\n";
	}
	if(length($port)>=3)
	{
		return($port);
	}
	else
	{
		print "Getting proxy\r";
		goto g;
	}
}

sub getcont2()
{
    my($ur,$cont,$ref,$method)=@_;
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
    my $res=$ua2->request($request);
    $cookie_jar->extract_cookies($res);
    $cookie_jar->save;
    $cookie_jar->add_cookie_header($request);
    my $code=$res->code;
    print"$code\n";
    if($code==200)
    {
       
        my $content=$res->content();
		$content=decode_entities($content);
        return ($content);
    }
    elsif($code=~m/50/is)
    {
        print"Net Failure\n";
        # sleep(30);
        goto netfail;
    }
    elsif($code=~m/30/is)
    {
       
		my $loc=$res->header("Location");
        print "Location: $loc\n";
        my $request1=HTTP::Request->new(GET=>$loc);
        $request1->header("Content-Type"=>"application/x-www-form-urlencoded");
        my $res1=$ua2->request($request1);
        $cookie_jar->extract_cookies($res1);
        $cookie_jar->save;
        $cookie_jar->add_cookie_header($request1);
        my $content1=$res1->content();
        return ($content1);

    }
    elsif($code=~m/40/is)
    {
		my $content=$res->content();
		# $content=decode_entities($content);
        return ($content);
        print "URL Not found\n";
    }
}