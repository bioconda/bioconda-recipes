#!/usr/bin/env perl
use Test::More tests=>12;
my $path;
BEGIN {$path  = `which HLAProfiler.pl`;
       chomp $path;
       $path=~s/HLAProfiler.pl//}

use lib $path;

my @commands = ("HLAProfiler.pl -h >/dev/null");

foreach my $cmd (@commands){
	my $out = system($cmd);
	if ($? != 0){
		print STDERR "\n$out\n";
		exit 1;
	}
	last;
}

my @modules = ("modules::AlleleRefiner", "modules::DetermineProfile", "modules::HLADistractome", "modules::HLAPredict", "modules::HLATaxonomy", "modules::MergeDuplicates", "modules::PairPicker", "modules::ReadCounter", "modules::RunKraken", "modules::SequenceFunctions", "modules::SimulateReads", "modules::TaxonomyDivisions");
foreach my $module (@modules){
	use_ok($module);
} 
