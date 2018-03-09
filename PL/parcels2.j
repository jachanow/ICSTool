#!/usr/bin/perl
# creates # DB of parcels geolocation information
# StreetName+StreetSufx -> StreetNum(s) 
# StreetName+StreetSuf+StreetNum ->  longitude latitude
use DB_File;
use XBase;
do "subCommon.pl";
#do "vAddress.pl";
$HOME=$ENV{HOME};
unlink "./DB/ParcelInfoByAddress.db";
tie(%parcelInfo,"DB_File","./DB/ParcelInfoByAddress.db",O_RDWR|O_CREAT,0666);
my $data = new XBase "$HOME/QGIS/Parcels.dbf" or die XBase->errstr;

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
  $key="$street=$address";
  $key=&vAddressFromArray("$street","$address");
  #
  $val=join("\t",@rec);
  $parcelInfo{"$key"}=$val;
  $recnum++;
  if($address ne 0 )
  { if( $xParcelStreetAdresses{"$street"} )
    { $xParcelStreetAdresses{"$street"} .= "\t$address"; 
    }
    else
    { $xParcelStreetAdresses{"$street"} = "$address"; 
    }
  }
}
unlink "./DB/ParcelStreetAddresses.db";
tie(%ParcelStreetAdresses,"DB_File","./DB/ParcelStreetAddresses.db",O_RDWR|O_CREAT,0666);
@s= sort keys %xParcelStreetAdresses;
foreach $s (@s)
{ $ParcelStreetAdresses{$s}=$xParcelStreetAdresses{$s};
  print $ParcelStreetAdresses{$s};
}
print "\n$#s\n";




