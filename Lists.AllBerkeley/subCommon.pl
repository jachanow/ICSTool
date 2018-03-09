#!/usr/bin/perl
#################################
use Fcntl;
use DB_File;
use POSIX qw(strftime);
use Time::Local;
############# global variables
$BlockSeparator="-----------------------------------";
# HTML parameters
$EntryType=$ENV{"QUERY_STRING"};
$EntryType=~s/CallType=(.*)/$1/;
$EntryType=~s/\+/ /g;
############# global variables

# default initialization 
sub initialization
{ use URI::Escape;
  use CGI::Carp qw/fatalsToBrowser/;
  use CGI qw/:standard/;
  $q = new CGI;
  &Set_timestr;
  &SetUrls;
} 

# converts URI encoded string to normal string
sub uri_unescape
{ my $string=@_[0];
  $string=~s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
  return $string;
}
# evaluate calling parameter string in form a=b&c=d
sub EvalParmString
{ my 
  $ParmString=&uri_unescape($ENV{"QUERY_STRING"});
  my @ParmString=split(/&/,$ParmString);
  foreach my $eqn (@ParmString)
  { my @eqn = split(/=/,$eqn,2);
    ${$eqn[0]}=$eqn[1];
  }
}

# hiddenParam passes parameters in $strlist as hidden parameter 
sub hiddenParam
{ my ($q,$strlist)=@_; #comma separated list; array values indicated by @name
  my @strparam=split(/,/,$strlist);
  for( my $i=0; $i<=$#strparam; $i++ )
  { my $name=$strparam[$i];
    if( $name =~ /^@/ ) # ARRAY variable
    { $name =~ s/^@//;
      my @value=&uniq( $q->param("$name") ); #DEBUG $q->hidden oddity
      if( @value )
      { print $q->hidden(-name=>"$name",-default=>[@value]);
      }
    }
    else
    { my $value=$q->param("$name");
      if( $value )
      { print $q->hidden("$name",$value); # 2013
      }
    }
  }
}

# use if the $q->hidden returns ARRAY()
sub deleteARRAY 
{ my @tmp = @_;
  my @out,$j;
  $j=0;
  for($i=0;$i<=$#tmp;$i++)
  { if( $tmp[$i] !~ /ARRAY/ )
    { $out[$j++]=$tmp[$i];
    }
  }
  return @out;
}

sub SetUrls
{ my $current_url      = url();
  my @path=split "/",$current_url ;
  $#path-=3;
  $HomeUrl=join "/",@path;  # set relative to ../ICC/PL
}

# Very important subroutine -- get rid of all the naughty
# metacharacters from the file name. If there are, we
# complain bitterly and die.
sub clean_name {
   my($name) = @_;
    $name=~s/^\s+//; #no leading blanks
    $name=~s/\s+$//; #no trailing blanks
    $name=~s/  / /g; #only single spaces
   return "$name";
}

# Jumps to a label in ../../labels.pl
# NEEDS to be before call to header
sub JumpToLabel
{ do "../../labels.pl";
  my ($label)=@_;
  $url=$HomeUrl;
  $url.=$external_labels{"$label"} ;
  print $q->redirect(-URL=>"$url");
  exit;
}

################################################
# Subroutines
sub TIE		#If this does not seem to work in WEB calls (CHECK permissions)
{ my @list=@_;
  my $type;
  foreach $type (@list)
  { if($type=~/\w/)
    { tie(%{$type},"DB_File","./DB/$type.db",O_RDWR|O_CREAT,0666) 
	or die "Check permissions: abort at tie ./DB/$type";
    }
  }
}

sub UNTIE
{ my @list=@_;
  foreach $type (@list) { untie %{$type}; }
}

#############################
# returns array from string with comma separator.  Delete spaces. Used in 
# converting .csv
sub MakeArray
{ my ($string)=$_[0]; # "label1, label2, label3")
  $string=~s/\s//g;
  return split(/,/,$string); 
}
#########################
##POD 
##POD uniq( @list )
##POD   return @unique_list from @list (strings)
sub uniq
{ local($i,$ii,$test1,$test2);
  local @retval;
  local ( @slist ) = sort (@_);
  for($i=0;$i<=$#slist;$i++)
  { my $test1=$retval[$ii-1];
    my $test2=$slist[$i];
    if ( $test1 ne $test2 ){ $retval[ $ii++ ] = $slist[$i]; }
  }
  return(@retval);
}

#########################
##POD 
##POD uniqCSV( $csv)
##POD   return @unique_CSV from $csv
sub uniqCSV
{ my $csv=$_[0];
  return join(",", &uniq( &MakeArray($csv) ) );
}

#########################
##POD 
##POD MemberQ( @list, $test )
##POD   return index to $test in @list (strings)
sub MemberQ
{ local($i); local($elem)=pop(@_);
  for($i=0;$i<=$#_;$i++) { return($i) if( $elem eq $_[$i] ); }
  return(-1);
}

# find first record with pattern
sub FindPattern 
{ local($i); local($pattern)=pop(@_);
  for($i=0;$i<=$#_;$i++) { return($i) if( $_[$i] =~ m/$pattern/ ); }
  return(-1);
}

##################
sub Set_timestr
{ use POSIX qw(strftime);
  $UXtime=time;
  $timestr= strftime "%a %b %e %H:%M %Y", localtime;
  $timeh1="<small>($timestr)</small>";
}

#POD return the index to first item in @list that matches /^$find/
sub FindMatchQ
{ my ($find,@list)=@_;
  my $i;
  for($i=0;$i<=$#list;$i++)
  { last if( $list[$i] =~ /^$find/ );
  }
  if($i<=$#list) { return($i) }
  else { return(-1) };
}

# returns 1 if all strings in @find are found in $base.
sub AllMatchQ
{ my ($base,@find)=@_;
  my $i;
  for($i=0;$i<=$#find;$i++)
  { last if( $base!~m/$find[$i]/i );
  }
  if($i==$#find+1) { return(1) }
  else { return(0) };
}

#POD default submit of action 
sub SubmitActionList
{ local($lab);
  local(@label)=@_;
  foreach $lab (@label)
  { print $q->submit('action',$lab);
  }
}

sub SubmitActionListWithComments
{ local(@label)=@_;
  local($lab);
  foreach $lab (@label)
  { print $q->submit('action',$lab), " $actioncomment{$lab} <BR>";
  }
}

sub COMMENT
{ my $c=$_[0];
  return "<font color=\"red\">$c<font color=\"black\">";
}

sub BOLD
{ my $c=$_[0];
  return "<strong>$c</strong>";
}

sub COLOR
{ my ($color,$text)=@_;
  return "<font color=\"$color\">$text<font color=\"black\">";
}

sub HTMLHeader
{ print $q->header(-type=>'text/html',-charset=>'utf-8');
  
  print $q->start_html(-title=>'ICC',
    -author=>'takato@pacbell.net',
    -style=>{'src'=>'./ICSTool.css'});
}

sub BlockDifference
{ my ($separator,@lines)=@_; # contains 2 blocks terminating with $separator 
  # returns 
  # added element to block1 relative to block2
  # $separator
  # added element to block2 relative to block1
  # $separator
  my $cnt;
  my @savelines;
  my @block1,@block2;
  $#block1=$#block2=-1;
  my $n=1;
  for(my $i=0;$i<=$#lines;$i++) #load 2 blocks
  { if($n==1){ push(@block1,$lines[$i]) }
    else { push(@block2,$lines[$i]) }
    if($lines[$i] =~ m/$separator/ ) { $n++; next; };
    last if ($n>2);
  }
  #find new block1 elements
  for(my $i=0;$i<=$#block1;$i++)
  { my $test=$block1[$i];
    $cnt=0;
    for(my $j=0;$j<=$#block2;$j++)
    { if($test eq $block2[$j] ) { $cnt++; last; }
    }
    if($cnt == 0 ) { push (@savelines,$test); }
  } 
  push(@savelines,$separator);
  #find new block2 elements
  for(my $i=0;$i<=$#block2;$i++)
  { my $test=$block2[$i];
    $cnt=0;
    for(my $j=0;$j<=$#block1;$j++)
    { if($test eq $block1[$j] ) { $cnt++; last; }
    }
    if($cnt == 0 ) { push (@savelines,$test); }
  } 
  push(@savelines,$separator);
  return @savelines; 
}

# input text file ignore lines that begin with # or NULL lines
# and delete end of line beginning with #
# Returns @array of lines
sub arrayTXTfile
{ my $file=@_[0];
  my @lines;
  open(L,"$file");
  while(<L>)
  { chop;
    next if( /^#/);	# comment
    $_=~s/#.*$//;	#trailing comment
    $_=~s/[\s]*$//;	#trailing space 
    $_=~s/^[\s]*//;	#leading space 
    next if( /^$/);	#null line
    push @lines,$_;
  }
  close L;
  return @lines;
}

#
sub saveArray2TXTfile
{ my ($file,@vars)=@_;
  open L,">$file";
  for( my $i; $i<=$#vars;$i++)
  { print L $vars[$i],"\n";
  }
}

# delete one item in array referenced by index
sub deleteArrayIndex
{ my ($index,@array)=@_;
  return @array[0 .. $index-1, $index-$#array .. -1 ];
}

# deletes "" items in array 
sub deleteNullItems
{ my @array=@_;
  for(my $i=0;$i<=$#array;$i++)
  { if( $array[$i] eq "" )
    { @array=&deleteArrayIndex($i,@array);
      $i--;
    }
  }
  return @array;
}

# delete matching element in array
sub deleteElement
{ my ($element,@array)=@_;
  for( my $i=0; $i<=$#array;$i++)
  { if( $element eq $array[$i] )
    { $array[$i]="";
    }
  }
  @array=&deleteNullItems(@array);
}

# returns @list from @array that has head $head. e.g., &selectHead($head,@array);
sub selectHead
{ my ($head,@array)=@_;
  my @out; $#out=-1;
  for( my $i=0;$i<=$#array;$i++)
  { if( $array[$i] =~ /^$head/)
    { push(@out,$array[$i]);
    }
  }
  return @out;
}

# loads CGI $file into $q namespace,
sub loadCGIfile
{ my ($file)=@_; 
  open(FILE,$file)||die "##$file not found";
  my $qfile = CGI->new(FILE);
  close(FILE);
  return($qfile);
}

# save $q namespace into CGI $file 
sub saveCGIfile
{ my ($q,$file)=@_; 
  open(FILE,">",$file)||die "##$file not found";
  $q->save(FILE);
  close(FILE);
}

# overwrites $parm with $value to CGI $file
sub newCGIfile
{ my ($file,@parmvalue)=@_; #pairs of parm,value
  my $qq = CGI->new;
  $qq->delete_all();
  for(my $i=0; $i<$#parmvalue;$i+=2)
  { my $parm=$parmvalue[$i];
    my $value=$parmvalue[$i+1];
    $qq->param($parm,$value);
  }
  open(FILE,'>',$file)||die "##addCGIfile $file";
  $qq->save(FILE);
  close(FILE);
}

# add $parm with $value to CGI $file
sub addCGIfile
{ my ($file,@parmvalue)=@_; #pairs of parm,value
  open(FILE,$file)||die "##$file not found";
  my $qq = CGI->new(FILE);
  for(my $i=0; $i<$#parmvalue;$i+=2)
  { my $parm=$parmvalue[$i];
    my $value=$parmvalue[$i+1];
    $qq->param($parm,$value);
  }
  close(FILE);
  open(FILE,'>',$file)||die "##addCGIfile $file";
  $qq->save(FILE);
}

# appends $parm with $value to CGI $file
sub logCGIfile
{ my ($file,@parmvalue)=@_; #pairs of parm,value
  my $qq = new CGI;
  for(my $i=0; $i<$#parmvalue;$i+=2)
  { my $parm=$parmvalue[$i];
    my $value=$parmvalue[$i+1];
    $qq->param($parm,$value);
  }
  my $append=">";
  if( -e $file) { $append=">>"; }
  open(FILE,$append,$file)||die "## died in logCGIfile $file";
  $qq->save(FILE);
  close FILE;
}

# selectNamespaceParam returns namespace of parameters in $strlist 
sub selectNamespaceParam
{ my ($q,$strlist)=@_; #comma separated list; array values indicated by @name
  my $qq=new CGI;
  $qq->delete_all();
  my @strparam=split(/,/,$strlist);
  for( my $i=0; $i<=$#strparam; $i++ )
  { my $name=$strparam[$i];
    if( $name =~ /^@/ ) # ARRAY variable
    { $name =~ s/^@//;
      my @value=&uniq( $q->param("$name") ); 
      if( @value )
      { $qq->param(-name=>"$name",-default=>[@value]);
      }
    }
    else
    { my $value=$q->param("$name");
      if( $value )
      { $qq->param("$name",$value); 
      }
    }
  }
  return $qq;
}

# saves $parm to CGI $file
sub saveParmsCGIfile
{ my ($q,$file,$parmlist)=@_;
  #print "##: ($q,$file,$parmlist)";
  my $qq=&selectNamespaceParam($q,$parmlist);
  open(FILE,'>',$file) || die "##saveParmsCGIfile:$file,:";
  $qq->save(FILE);
  $qq->delete_all();
  close(FILE);
}

# add/replace $parm to CGI $file
sub addParmsCGIfile
{ my ($q,$file,$parmlist)=@_; 
  my  $qq = new CGI;
  $append=">";
  if( -e $file ) # LOAD data
  { open(FILE,$file)||die "##$file not found";
    $qq = CGI->new(FILE);
  }
  my @parmlist=split(/,/,$parmlist);
  for( my $i=0; $i<=$#parmlist; $i++ )
  { my $name=$parmlist[$i];
    if( $name =~ /^@/ ) # ARRAY variable
    { $name =~ s/^@//;
      my @value=&uniq($q->param($name));
      if( @value )
      { $qq->param(-name=>"$name",-default=>[@value]);
      }
    }
    else
    { my $value=$q->param("$name");
      if( $value )
      { $qq->param("$name",$value); 
      }
    }
  }
  open(FILE,$append,$file)||die "##addCGIfile $file";
  $qq->save(FILE);
}

# saves $parm to CGI $file
sub logParmsCGIfile
{ my ($q,$file,$parmlist)=@_;
  my $append;
  my $qq=&selectNamespaceParam($q,$parmlist);

  $append=">";
  if( -e $file) { $append=">>" }
  open(FILE,$append,$file)||die "##logParmsCGIfile:$file";
  $qq->save(FILE);
  close(FILE);
  $qq->delete_all();
}

sub DEBUG
{ my @var=@_;
   return();
  my $str="DEBUG: @var";
  print &COLOR("blue",$str),"<br>";
}

# interprets array of PARM=VAL strings into ${PARM}=VAL.
sub ParmValueArray
{ my @array=@_;
  foreach my $line (@array)
  { my ($parm,$value)=split(/=/,$line,2);
    ${$parm}=$value;
  }
}

