#!/usr/bin/perl
# makes DB/MapStreetAddressesEmPrep.db and DB/MapStreetAddressLLEmPrep.db
# DB/MapStreetAddressPIXEmPrep.db
use DB_File;
do "subCommon.pl";
do "vAddress.pl";
$HOME=$ENV{HOME};
$Lists="Lists";
#
unlink("./DB/MapStreetAddressesEmPrep.db");
unlink("./DB/MapStreetAddressLLEmPrep.db");
unlink("./DB/MapStreetAddressPIXEmPrep.db");
tie(%StreetAddresses,"DB_File","./DB/MapStreetAddressesEmPrep.db",O_RDWR|O_CREAT,0666);
tie(%StreetAddressLL,"DB_File","./DB/MapStreetAddressLLEmPrep.db",O_RDWR|O_CREAT,0666);
tie(%StreetAddressPIX,"DB_File","./DB/MapStreetAddressPIXEmPrep.db",O_RDWR|O_CREAT,0666);
open L,"$Lists/MapStreetAddressLLEmPrep.txt";
while(<L>)
{ chop;
  ($StreetAddress,$lat,$long,$px,$py) = split(/\t/,$_);
  ($street,$address)=&vAddress2Array($StreetAddress);

  $StreetAddresses{$street}.="$address\t";
  $StreetAddressLL{"$StreetAddress"}="$lat\t$long\t$px\t$py";
  $StreetAddressPIX{"$StreetAddress"}="$px\t$py";
}
foreach $s ( keys %StreetAddresses )
{ print "$s ", $StreetAddresses{$s},"\n";
}
exit;

