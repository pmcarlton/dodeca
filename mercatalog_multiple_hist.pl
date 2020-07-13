#!/usr/bin/env perl
# mercatalog_hist:
# using input N for N-mer size, output a histogram catalog of all N-mers
# works with multiple sequence files:
# creates equal number of bins on each file, puts them all in the same catalog 
# structure...
# 2019-02-21 pmc

use strict;
use warnings;

my $bins=20;
my $n=6; # mer length
my %catalog;

my $seqs=($#ARGV); #number of sequences to read in, provided on command line
my $bintotal=$bins*($seqs+1); #number of entries in the catalog for each mer

my $offset=0; # offset to add each mer count to its corresponding position in the catalog
foreach my $fname(@ARGV) { #sequence to read
my $seq=slurp($fname);
$seq=~s/\n//g;

my $l=length($seq);
my $lb=$l/$bins;

for (my $li=0;$li<=($l-$n);$li++) {
my $mer=substr($seq,$li,$n);
my $rem=revcomp($mer);

@{$catalog{$mer}}=(0)x$bintotal unless $catalog{$mer}; #make an all-0 entry for the mer and its complement \
@{$catalog{$rem}}=(0)x$bintotal unless $catalog{$rem}; #in the catalog if it doesn't already exist yet

my $pos=int($li/$lb); #which bin of the sequence contains the mer?
${$catalog{$mer}}[$pos+$offset]+=1; #add one to the bins \
${$catalog{$rem}}[$pos+$offset]+=1; #that contain the mer

}

$offset+=$bins; # add to the offset for each new sequence

} # end $fname

for (my $li=0; $li<=$#ARGV; $li++) {
    for (my $lj=0; $lj<$bins; $lj++) {
        print $ARGV[$li],"_",$lj," ";
    }
}
print("\n");

for my $key (sort( keys(%catalog))) {
    print($key);
for (my $li=0;$li<$bintotal;$li++) {
    print (" ",${$catalog{$key}}[$li]);
    }
print("\n");
}

sub slurp { # from https://perlmaven.com/slurp (Gabor Szabo)
    my $file = shift;
    open my $fh, '<', $file or die;
    local $/ = undef;
    my $cont = <$fh>;
    close $fh;
    return $cont;
}

sub revcomp {
	my $seq = shift;
	$seq = reverse($seq);
	$seq =~ tr/acgtACGT/tgcaTGCA/;
	return $seq;
}
