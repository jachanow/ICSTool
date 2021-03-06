#!/usr/bin/perl
# creates # DB of parcels geolocation information from "$HOME/QGIS/Parcels.dbf" 
# outputs:
# 	%parcelInfo,"./DB/ParcelInfoByAddress.db" of "$HOME/QGIS/Parcels.dbf"
#	%ParcelStreetAddresses,"./DB/ParcelStreetAddresses.db"
# 		StreetName=StreetSufx= -> StreetNum(s) 
#	%ParcelLonLatByAddress,"./DB/ParcelLonLatByAddress.db"
#		StreetName=StreetSuf=StreetNum= ->  Longitude\tLatitude
use DB_File;
use XBase;
do "subCommon.pl";
#do "vAddress.pl";
$HOME=$ENV{HOME};
unlink "./DB/ParcelInfoByAddress.db";
my $data = new XBase "$HOME/QGIS/Parcels.dbf" or die XBase->errstr;
tie(%parcelInfo,"DB_File","./DB/ParcelInfoByAddress.db",O_RDWR|O_CREAT,0666);

$recnum=1;
while(@rec = $data->get_record($recnum,"StreetNum","StreetName","StreetSufx","City","State","Zip","longitude","latitude","UseCode","UseCodeDes","BldgSqft",
    "U_X","U_Y","U_Xmin","U_Ymin","U_Xmax","U_Ymax"
  )
)
{ shift @rec; #eliminate rec cnt. 
  $address=$rec[0];
  $street="$rec[1] $rec[2]";
  $street =~ s/([\w']+)/\u\L$1/g;
  $city="$rec[3]";
  $city =~ s/([\w']+)/\u\L$1/g;
  $key=&vAddressFromArray("$street","$address");
  #
  $val=join("\t",@rec);
  $parcelInfo{"$key"}=$val;
  $recnum++;
  if($address ne 0 )
  { if( $xParcelStreetAddresses{"$street"} )
    { $xParcelStreetAddresses{"$street"} .= "\t$address"; 
    }
    else
    { $xParcelStreetAddresses{"$street"} = "$address"; 
    }
    $xParcelLonLat{"$key"}="$rec[6]\t$rec[7]";
  }
}

unlink "./DB/ParcelStreetAddresses.db";
tie(%ParcelStreetAddresses,"DB_File","./DB/ParcelStreetAddresses.db",O_RDWR|O_CREAT,0666);
@s= sort keys %xParcelStreetAddresses;
foreach $s (@s)
{ $ParcelStreetAddresses{$s}=$xParcelStreetAddresses{$s};
  print $ParcelStreetAddresses{$s};
}
print "\n$#s\n";

unlink "./DB/ParcelLonLatByAddress.db";
tie(%parcelLonLat,"DB_File","./DB/ParcelLonLatByAddress.db",O_RDWR|O_CREAT,0666);
@s= sort keys %xParcelLonLat ;
foreach $s (@s)
{ $parcelLonLat{$s}=$xParcelLonLat{$s};
  print "$s : $parcelLonLat{$s}\n";
}
print "\n$#s\n";




