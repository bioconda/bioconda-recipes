#!/usr/bin/env perl
# xiechaos@gmail.com
use strict;
use IO::File;

die "usage: $0 input-fasta[fastq] m8.1 m8.2 [more m8 files]\n" unless $#ARGV >= 2;

my $infile = shift;
my @m8 = @ARGV;
my %m8;
for(@m8)
{
	my $fh = IO::File->new($_);
	$m8{$_} = $fh;
}

$infile = "zcat '$infile' |" if $infile =~ m/\.gz$/i;
$infile = "bzcat '$infile' |" if $infile =~ m/\.bz2?$/i;
open(IN, $infile) or die;

my @seq;
more_seq();

my %match;
more_match();

my $seq = shift @seq;
while(@seq or $seq)
{
	my %score;
	my $max;
	for my $f(@m8)
	{
		if($match{$f} =~ m/^\Q$seq\E\t.+\t(\S+?)$/)
		{
			$score{$f} = $1;
			$max = $1 if $1 > $max;
		}
	}

	my $printed;
	for my $f(keys %score)
	{
		if($score{$f} == $max)
		{
			print $match{$f};
			delete $match{$f};
			$printed = 1;
		}
	}

	if($printed)
	{
		more_match();
	}else
	{
		$seq = shift @seq;
		more_seq() unless @seq;
	}

}



sub more_seq
{
	my $count = 1000;
	while(<IN>)
	{
		if(m/^[>@](\S+)/)
		{
			push @seq, $1;
			$count--;
			last if $count <= 0;
		}
	}
}

sub more_match
{
	my $more;
	for my $f(@m8)
	{
		$match{$f} = $m8{$f}->getline() unless $match{$f};
		$more = 1 if $match{$f};
	}
	return $more;
}

