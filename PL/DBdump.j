#!/usr/bin/perl
require "subCommon.pl";
require "subDamageReport.pl";

#&TIE(DBrecSpecialNeeds);
$DB="DBrecPets";
$DB="DBrecVisitors";
$DB="DBrecEmergencyEquipment";
$DB="DBrecSpecialNeeds";
$DB="DBrecSpecialNeeds";
$DB="DBSpecialNeeds";
$DB="DBAddressOnStreet";
$DB="ParcelInfoByAddress";
$DB="ParcelStreetAddresses";
$DB="MapStreetAddressLL";
$DB="MapStreetAddressLLEmPrep";
$DB="MapStreetAddressPIXEmPrep";
$DB="ParcelLonLatByAddress";
&TIE($DB);
@key=keys %{$DB};
for(my $i=0;$i<=$#key;$i++)
{ print "========\n";
  print ">>$key[$i]:\n >",join("\n >",split(/\t/,${$DB}{$key[$i]})),"\n";
}
 






