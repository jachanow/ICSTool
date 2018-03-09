#!/usr/bin/perl
#
sub addArrays
{ my @a=@_;
  my @c; 
  my $size=($#a+1)/2;
  for(my $i=0; $i<$size; $i++) { $c[$i]=$a[$i]+$a[$i+$size] }
  return(@c);
}

@a=(1,2,9);
@b=(3,4,9);
#print "@a : @b ",&addArrays(@a,(9,9,9));

%pltdata=(xybase => [22,33],markerSize=>2,markers=>["00","01","10","11"]);
&printMarker(pltdata);

sub printMarker
{ my ($data)=@_;
  my (@xybase,$xy00,$xy10,$xy01,$xy11,$markerSize);
  @xybase=@{${$data}{xybase}};
  $markerSize=${$data}{markerSize};
  @markers=@{${$data}{markers}};
  print "$subSize, $markerSize, @markers";
}
