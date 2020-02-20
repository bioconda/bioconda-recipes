#!/usr/bin/perl -w


use FindBin;

#set -x -e
my $home_directory = $FindBin::Bin; 
chdir $home_directory;
# run gcluster
system ("Gcluster -dir test_data/gbk -gene test_data/interested_gene_name.txt -tree test_data/16S_rRNA_tree.nwk -m 3");

print "--------$home_directory---------\n";
rm -rf test_data;
