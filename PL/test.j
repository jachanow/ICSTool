#!/usr/bin/perl
require "subCommon.pl";
&initialization;

###########################################################################
&TIE(DBSpecialNeeds);
while (my ($key,$val) = each %DBSpecialNeeds) 
{
  #print $key, ' = ', unpack('L', $val), "\n";
  print "$key :: $val \n";
}
