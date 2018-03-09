#!/usr/bin/perl
use DB_File; 
$HOME=$ENV{HOME};
tie(%parcel,"DB_File","./DB/ParcelInfoByAddress.db",O_RDWR,0666);
tie(%ParcelStreetAdresses,"DB_File","./DB/ParcelStreetAddresses.db",O_RDWR,0666);
@s=keys %ParcelStreetAdresses;
#print join("\n",@s);
foreach $s (@s)
{ 
  #print "\n$s\n",join("\n", split("\t",$ParcelStreetAdresses{$s} ) );
  map { $add="$_ $s";
    @p=split("\t",$parcel{$add});
    print "$add: $p[6], $p[7]\n"; }
      split( "\t",$ParcelStreetAdresses{$s} ) 
}

print "\n$#s";



