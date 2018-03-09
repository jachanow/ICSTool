#!/usr/bin/perl
use URI::Escape;
use Fcntl;
use DB_File;
use POSIX qw(strftime);
use Time::Local;
use CGI::Carp qw/fatalsToBrowser/;
use CGI qw/:standard/;
require "subCommon.pl";

@a=(1,2,3);
print "@a";
@a=&deleteArrayIndex(1,@a);
print "\n@a";
