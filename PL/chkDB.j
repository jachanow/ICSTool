#!/usr/bin/perl
# Prints data in DB files
# Use: getDBinfo.j <field> <firstname lastname>
# <field> == (email,cell,contact,address)
do "subMemberDB.pl";
do "subMessageSystem.pl";
print "@DBname\n";
#############################
$db= $DBname[4];
$db= $DBname[0];
$db="Messages";
$db="MapStreetAddresses";

$db= $DBname[0];
&TIE( "$db");
foreach $key (keys %{$db})
{ print ">> $key\n", ${$db}{$key},"\n";
}
print "======$db";

