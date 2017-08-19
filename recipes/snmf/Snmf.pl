#!/usr/bin/perl

use strict;
use Switch;
use Getopt::Long;
use Bio::SeqIO;

my $usage = qq~Usage:$0 <args> [<opts>]
where <args> are:
    -i, --input         <input VCF>
    -o, --output        <output>
    -k, --kmin          <K min>
    -m, --maxK          <K max>
    -d, --directory     <temporary directory>
    -t, --threshold     <threshold admixture proportion for group assignation>
~;
$usage .= "\n";

my ($input,$output,$kmin,$kmax,$directory,$threshold);


GetOptions(
	"input=s"      => \$input,
	"output=s"     => \$output,
	"kmin=s"       => \$kmin,
	"maxK=s"       => \$kmax,
	"directory=s"  => \$directory,
	"threshold=s"  => \$threshold
);


die $usage
  if ( !$input || !$output || !$kmin || !$kmax || !$directory || !$threshold);
  

my $PLINK_EXE = "./plink";

system("$PLINK_EXE --vcf $input --allow-extra-chr --recode vcf-fid --out $directory/input >>$directory/logs 2>&1");

system("./bin/vcf2geno $directory/input.vcf $directory/polymorphisms.geno >>$directory/logs 2>&1");


my $ind_cmd = `grep '#CHROM' $input`;
chomp($ind_cmd);
my @individuals = split(/\t/,$ind_cmd);shift @individuals;shift @individuals;shift @individuals;shift @individuals;shift @individuals;shift @individuals;shift @individuals;shift @individuals;

###################################
# launch admixture for different K
###################################
my %errors;
for (my $k = $kmin; $k <= $kmax; $k++)
{
	system("sNMF -x $directory/polymorphisms.geno -K $k -c >>$directory/log.$k 2>&1");

	open(my $O3,">$directory/out.$k.group");
	open(my $O2,">$directory/out.$k.final.Q");

	my $ent;
	open(my $LOG,"$directory/log.$k");
	while(<$LOG>){
		if (/Cross-Entropy \(masked data\).*(\d+\.\d+)$/){
			$ent = $1;
			$errors{$ent} = $k;
		}
	}
	close($LOG);

	open(E,">>$directory/entropy");
	print E "K=$k $ent\n";
	close(E);

	print $O2 "Indiv";
	print $O3 "Indiv;Group\n";
	for (my $j = 0; $j <$k; $j++){
		print $O2 "	Q$j";
	}
	print $O2 "\n";

	open(my $O,"$directory/polymorphisms.$k.Q");
	my %hash_groupes;
	my %hash_indv;
	my %group_of_ind;
	my $i = 0;
	while (<$O>){
		$i++;
		my $line = $_;
		$line =~s/\n//g;
		$line =~s/\r//g;
		my @infos = split(/\s+/,$line);
		my $group = "admix";
		my $ind = $individuals[$i];
		for (my $j = 0; $j <$k; $j++){
			my $val = $infos[$j];
			if ($val > 0.5){$group = "Q$j";}
		}
		if ($ind){
			$hash_indv{$ind} = join("	",@infos);
			$hash_groupes{$group}{"ind"} .= ",".$ind;
			$group_of_ind{$ind} = $group;
		}
	}
	close($O);
		
	foreach my $group(sort keys(%hash_groupes)){
		my @inds = split(",",$hash_groupes{$group}{"ind"});
		foreach my $ind(@inds){
			if ($ind =~/\w+/){
				print $O3 "$ind;$group\n";
				print $O2 $ind."	".$hash_indv{$ind}. "\n";
			}
		}
	}

	system("cat $directory/log.$k >>$directory/logs");
	system("echo '\n\n====================================\n\n' >>$directory/logs");
	system("cat $directory/out.$k.final.Q >>$directory/outputs.Q");
	system("echo '\n\n====================================\n\n' >>$directory/outputs.Q");
}

my @sorted_errors = sort {$a<=>$b} keys(%errors);
my $best_K = $errors{@sorted_errors[0]};


system("cp -rf $directory/out.$best_K.final.Q $directory/output");

system("cp -rf $directory/log.$best_K $directory/log");
system("cp -rf $directory/out.$best_K.group $directory/groups");
