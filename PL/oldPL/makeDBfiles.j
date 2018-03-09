#!/usr/bin/perl
#system "cp -pPRf ../../Resources/DB/MasterDB.csv ./DB/";
system "MasterDB.csv2db.pl";
system "mkAddressList.pl";
system "parcels2.j";
system "parcelStreetAddresses.j";
system "makeMapStreetAddressEmPrep.j";
system "cd ../..; ./setPermission.j";
unlink "DB/Messages.db";
unlink "DB/Personnel.db";
unlink "DB/ResponseTeams.db";
unlink "DB/SpecialNeeds.db";

