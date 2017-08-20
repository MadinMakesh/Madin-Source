use strict;
use Data::Dumper;
use List::Pairwise qw( grep_pairwise );
open AB,">check2.txt";
close AB;
# open FH,">without_dup.txt";
# close FH;
open FH,"<input36.txt";
my @array=<FH>;
# my %seen = ();
# my @unique = grep { ! $seen{ $_ }++ } @array;
# open AB,">>check2.txt";
# print AB "@unique\n";
# close AB;
my %hash;
foreach my $array(@array)
{
	my ($SNO,$BRAND,$COMPANY_NAME,$ADDDRESS,$ADDRESS1,$ADDRESS2,$CITY,$STATE,$ZIP,$COUNTRY,$PHONE_NUMBER1,$PHONE_NUMBER2,$FAX,$E_MAIL,$WEBSITE,$OUTPUT_URL,$INPUT_URL,$input_zipcode,$input_code,$input_region,$input_lat,$input_lng)=split("\t",$array);
	chomp($SNO,$BRAND,$COMPANY_NAME,$ADDDRESS,$ADDRESS1,$ADDRESS2,$CITY,$STATE,$ZIP,$COUNTRY,$PHONE_NUMBER1,$PHONE_NUMBER2,$FAX,$E_MAIL,$WEBSITE,$OUTPUT_URL,$INPUT_URL,$input_zipcode,$input_code,$input_region,$input_lat,$input_lng);
	chomp($COMPANY_NAME);
	chomp($ADDRESS1);
	chomp($ADDRESS2);
	chomp($CITY);
	chomp($STATE);
	chomp($ZIP);
	chomp($COUNTRY);
	if($STATE=~m/\-/igs)
	{
		goto bow;
	
	}
	# print "$sno\t****";
	my $key=$SNO."|".$BRAND."|".$COMPANY_NAME."|".$ADDDRESS."|".$ADDRESS1."|".$ADDRESS2."|".$CITY."|".$STATE."|".$ZIP."|".$COUNTRY."|".$PHONE_NUMBER1."|".$PHONE_NUMBER2."|".$FAX."|".$E_MAIL."|".$WEBSITE."|".$OUTPUT_URL."|".$INPUT_URL."|".$input_zipcode."|".$input_code."|".$input_region."|".$input_lat."|".$input_lng;
	my $ca=lc($COMPANY_NAME."|".$ADDRESS1.$ADDRESS2.$CITY.$STATE.$ZIP.$COUNTRY);
	$ca=~s/\s+//igs;
	# print "ca******$ca\n";
	# print "$ca\n\n";<>;
	$hash{$key} = $ca;
	
	bow:
	# for(my $i=0;$i<=$#$array;$i++)
	# {
		# $array[$i]=~s/\s+//;
		# lc($array[$i]);
		# if(@array=~m/$array/is)
		# {
			# print "Nope\n";
		
		# }
		# else
		# {
			# open AB,">>check2.txt";
			# print AB "$array\n";
			# close AB;
		# }
	# }
	
}

print "collected\n";

my %counts = ();
my @counts = ();
my %unique = ();
foreach my $key (sort keys %hash) {
    my $value = $hash{$key}; 
    if (not exists $counts{$value}) {
        $unique{$key} = $value;
    }
    $counts{$value}++;
};
my @unique_keys = sort keys %unique; # Fix the sorting to your desired one 
                                     # if default is not what you meant

# You can also use %counts hash directly 
#instead of pushing values into an array as you wanted above.
foreach my $key (@unique_keys) {
    push @counts, $counts{ $unique{$key} }
};
# my %count;
# for my $ip ( values %hash ) { $count{ $ip }++ }
# my %hash2 = grep_pairwise { $count{ $b } == 1 ? ( $a => $b ) : () } %hash;
# my %seen;
# for my $key (keys %hash) {
    # my $value_key = "@{[values %{$hash{$key}}]}";
    # if (exists $seen{$value_key}) {
         # delete $hash{$key};
    # }
    # else {
        # $seen{$value_key}++;
    # }
# }
# my %t;
# $t{$_}++ for values %hash; #count values
# my @keys = grep
               # { $t{ $hash{ $_ } } == 1 }
           # keys %hash; #find keys for slice
# my %hash2;
# @hash2{ @keys } = @hash{ @keys };
while( my( $key, $value ) = each %unique )
{
	print "$key******$value\n";
	open FH,">>without_dup.txt";
	print FH "$key\t$value\n";
	close FH;

}
print "compleated\n";
# print Dumper %hash;<>;

# print "\n\n***\n\n";

# print keys	%hash;<>;	

# print "\n\n***\n\n";


# print keys	%hash2;<>;

# print output "$key : ", join(" ", uniq @{ $hash{$key} }) , "\n";

# my @sarray=sort @array;
