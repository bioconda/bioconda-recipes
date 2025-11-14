#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;

# ===============================
# 参数定义
# ===============================
my ($align_file, $ref_coord, $query_coord, $output_file, $help);
my $alignType = '';
GetOptions(
    "align=s" => \$alignType,
	"synteny=s" => \$align_file,
    "ref=s"   => \$ref_coord,
    "query=s" => \$query_coord,
    "out=s"   => \$output_file,
    "help|h"  => \$help,
) or die "❌ Error in command line arguments.\n";

# ===============================
# 帮助信息
# ===============================
if ($help or not $alignType or not $align_file or not $ref_coord or not $query_coord) {
    print <<"USAGE";
Usage:
  perl merge_synteny_info.pl --align <blastp|mmseqs|diamond> --synteny <alignment.tsv> --ref <ref_coord.tsv> --query <query_coord.tsv> [--out <output.tsv>]

Description:
  This script merges alignment results with coordinate information from two genomes.
  It reads:
    (1) Select alignment software, such as blastp, mmseqs, or diamond.
    (2) protein alignment file (two columns: ref_ID, query_ID)
    (3) reference genome protein coordinate file
    (4) query genome protein coordinate file
  and produces a combined output showing the synteny block information.

Options:
  --align           blastp, mmseqs, or diamond (required)
  --synteny <file>  Protein alignment file (required)
  --ref <file>      Reference genome protein coordinate file (required)
  --query <file>    Query genome protein coordinate file (required)
  --out <file>      Output merged TSV file [default: merged_result.tsv]
  -h, --help        Show this help message

Input example (coordinate file):
  OsMH_01T0000100-mRNA-1  Chr01    14381   31631   +
  OsMH_01T0000200-mRNA-1  Chr01_T  34165   39967   -

Output example:
  #Rchr  Rstart     Rend     Qchr     Qstart     Qend     Strand  Rname  Qname
  Chr01  32737650   35973282 Chr01_T  32205366   35440406 +       NA      NA

Example:
  perl merge_synteny_info.pl --align blastp --synteny blastp.tsv --ref MH63.protein.coord.tsv --query T.protein.coord.tsv --out synteny.merge.tsv
USAGE
    exit;
}
$alignType = lc($alignType);
#mmseqs的第1列和第2列是正确的$ref、$query
#blastp和diamond的比对文件输出第1列和第2列是反的
if(($alignType eq 'blastp') or ($alignType eq 'diamond'))
{
	my $key1 = $ref_coord;
	my $key2 = $query_coord;
	$ref_coord = $key2;
	$query_coord = $key1;
}


# 默认输出名
my $prefix1 = $align_file;
$prefix1 =~ s/\.[^.]+$//;
my $output1 = $prefix1 . '.tsv';
$output_file ||= $output1;

# ===============================
# 读取参考基因组坐标
# ===============================
my %ref_info;
open(my $IN1, "<", $ref_coord) or die "Cannot open $ref_coord: $!";
while (<$IN1>) {
    chomp;
    next if /^#/ || /^\s*$/;
    my ($id, $chr, $start, $end, $strand) = split /\t/;
    $ref_info{$id} = {
        chr    => $chr,
        start  => $start,
        end    => $end,
        strand => $strand,
    };
}
close $IN1;

# ===============================
# 读取查询基因组坐标
# ===============================
my %query_info;
open(my $IN2, "<", $query_coord) or die "Cannot open $query_coord: $!";
while (<$IN2>) {
    chomp;
    next if /^#/ || /^\s*$/;
    my ($id, $chr, $start, $end, $strand) = split /\t/;
    $query_info{$id} = {
        chr    => $chr,
        start  => $start,
        end    => $end,
        strand => $strand,
    };
}
close $IN2;

# ===============================
# 输出结果文件
# ===============================
open(my $OUT, ">", $output_file) or die "Cannot write to $output_file: $!";
print $OUT "#Rchr\tRstart\tRend\tQchr\tQstart\tQend\tStrand\tRname\tQname\n";

open(my $IN3, "<", $align_file) or die "Cannot open $align_file: $!";
while (<$IN3>) {
    chomp;
    next if /^#/ || /^\s*$/;
    my ($rid, $qid) = split /\t/;
	#print"$rid\t$qid\n";
    next unless exists $ref_info{$rid} && exists $query_info{$qid};
    my $ref = $ref_info{$rid};
    my $qry = $query_info{$qid};
    my $strand = ($ref->{strand} eq $qry->{strand}) ? "+" : "-";
    print $OUT join("\t", $ref->{chr}, $ref->{start}, $ref->{end}, $qry->{chr}, $qry->{start}, $qry->{end}, $strand, $rid, $qid), "\n";
}
close $IN3;
close $OUT;

print "✅ Output file generated: $output_file\n";
