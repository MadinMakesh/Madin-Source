sub scoring_status()
{
	my($companyname_input,$address_input,$city_input,$state_input,$zip_input,$phone_input,$companyname_output,$address_output,$city_output,$state_output,$zip_output,$phone_output)=@_;
	my $Output_status="NO";
	my $Status;
	#### Company and Address cleanup
	my $companyname_input=&company_cleanup($companyname_input);
	my $address_input=&address_cleanup($address_input);
	my $companyname_output=&company_cleanup($companyname_output);
	my $address_output=&address_cleanup($address_output);
	#### Bigram Scoring
	my $Company_Name_bigram_Score=bigram_score($companyname_input,$companyname_output);
	my $Address_bigram_Score=bigram_score($address_input,$address_output);
	my $city_bigram_Score=bigram_score($city_input,$city_output);
	my $state_bigram_Score=bigram_score($state_input,$state_output);
	my $zip_bigram_Score=bigram_score($zip_input,$zip_output);
	my $phone_bigram_Score=bigram_score($phone_input,$phone_output);
	#### Trigram Scoring
	my $Company_Name_trigram_Score=trigram_score($companyname_input,$companyname_output);
	my $Address_trigram_Score=trigram_score($address_input,$address_output);
	my $city_trigram_Score=trigram_score($city_input,$city_output);
	my $state_trigram_Score=trigram_score($state_input,$state_output);
	my $zip_trigram_Score=trigram_score($zip_input,$zip_output);
	my $phone_trigram_Score=trigram_score($phone_input,$phone_output);
	#### Token Scoring
	my $Company_Name_token_Score=Jaccord_Score($companyname_input,$companyname_output);
	my $Address_token_Score=Jaccord_Score($address_input,$address_output);
	my $city_token_Score=Jaccord_Score($city_input,$city_output);
	my $state_token_Score=Jaccord_Score($state_input,$state_output);
	my $zip_token_Score=Jaccord_Score($zip_input,$zip_output);
	my $phone_token_Score=Jaccord_Score($phone_input,$phone_output);
	
	#### Scoring Logic			
	#### Case1
	if((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)==100)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=90)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)>0))
	{
		$Status="Very High confidence";
		$Output_status="VH - Exact";
	}#### Case2
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>=75)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<=100)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=70)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)<=100)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)>0))
	{
		$Status="High confidence";
		$Output_status="HC1 - Good";
	}#### Case3
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>=75)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<=100)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=0)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)>=0)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)>=0)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)>=0)&&(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100))
	{
		$Status="High confidence";
		$Output_status="HC2 - Good";
	}#### Case4
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>=50)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<=75)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)>=0))
	{
		$Status="High confidence";
		$Output_status="HC3 - Good";
	}#### Case5
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>=75)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<=100)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)<100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Medium confidence ";
		$Output_status="MC1 - Eyeball";
	}#### Case6
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>=75)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<=100)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>=75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==0)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Medium confidence ";
		$Output_status="MC2 - Eyeball";
	}#### Case7
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>50)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<75)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>60)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)<75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Medium confidence ";
		$Output_status="MC3 - Eyeball";
	}#### Case8
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<50)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>65)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Medium confidence ";
		$Output_status="MC4 - CN Not match";
	}#### Case9
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>50)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<75)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>60)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)<75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)==100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==0)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Low confidence";
		$Output_status="LC1 - Must Check";
	}#### Case10
	elsif((($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)>50)&&(($Company_Name_bigram_Score||$Company_Name_trigram_Score||$Company_Name_token_Score)<75)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)>60)&&(($Address_bigram_Score||$Address_trigram_Score||$Address_token_Score)<75)&&(($city_bigram_Score||$city_trigram_Score||$city_token_Score)<=100)&&(($state_bigram_Score||$state_trigram_Score||$state_token_Score)==100)&&(($zip_bigram_Score||$zip_trigram_Score||$zip_token_Score)==100)&&((($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==0)||(($phone_bigram_Score||$phone_trigram_Score||$phone_token_Score)==100)))
	{
		$Status="Low confidence";
		$Output_status="LC2 - Must Check";
	}
	return ($Output_status,$Status,$Company_Name_bigram_Score,$Address_bigram_Score,$city_bigram_Score,$state_bigram_Score,$zip_bigram_Score,$phone_bigram_Score,$Company_Name_trigram_Score,$Address_trigram_Score,$city_trigram_Score,$state_trigram_Score,$zip_trigram_Score,$phone_trigram_Score,$Company_Name_token_Score,$Address_token_Score,$city_token_Score,$state_token_Score,$zip_token_Score,$phone_token_Score);
}