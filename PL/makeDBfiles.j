#!/usr/bin/perl
unlink "DB/*.db"; # linux.db incompatible with OSX.db WARN: includes all ICSTool.db files May want to be selective
system "csvFix.j"; # edit first to point to the correct csv file
system "MasterDB.csv2db.pl";
system "mkAddressList.pl";
system "mkParcelLonLatDB.j";
system "parcelStreetAddresses.j";
system "makeMapStreetAddressEmPrep.j";
system "(cd ../..; ./setPermission.j)";
# check 
unlink "DB/Messages.db";
unlink "DB/Personnel.db";
unlink "DB/ResponseTeams.db";
#unlink "DB/SpecialNeeds.db";

