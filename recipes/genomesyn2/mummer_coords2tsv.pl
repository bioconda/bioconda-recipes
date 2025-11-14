#!/usr/bin/env perl
use strict;
use warnings;

# 参数变量
my ($input, $output);

# 参数解析
for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq '--in') {
        if (defined $ARGV[$i+1] and $ARGV[$i+1] !~ /^--/) {
            $input = $ARGV[$i+1];
            $i++;
        }
    }
    elsif ($ARGV[$i] eq '--out') {
        if (defined $ARGV[$i+1] and $ARGV[$i+1] !~ /^--/) {
            $output = $ARGV[$i+1];
            $i++;
        }
    }
}

# 检查参数
if (not defined $input or not -f $input) {
    die "Error: --in file missing or not found.\nUsage: $0 --in <input_file> --out <output_file>\n";
}
if (not defined $output) {
    die "Error: --out must be specified.\nUsage: $0 --in <input_file> --out <output_file>\n";
}

# 打开输入输出文件
open my $IN,  "<", $input  or die "Cannot open input file $input: $!\n";
open my $OUT, ">", $output or die "Cannot write to output file $output: $!\n";

# 打印表头
print $OUT join("\t", "#Rchr","Rstart","Rend","Qchr","Qstart","Qend","Strand","Rname","Qname"), "\n";

while (<$IN>) {
    chomp;
	next if /^#/;  # 跳过以 # 开头的注释行
	next if /^\s*$/;  # 跳过空行
    my @f = split(/\s+/, $_);

    # 至少要有 13 列
    next unless @f >= 13;
    my $Rchr = $f[11];
	my $Qchr = $f[12];
	my $X0 = $f[0];
	my $X1 = $f[1];
	my $X2 = $f[2];
	my $X3 = $f[3];
	my ($Rstart, $Rend) = sort { $a <=> $b } ($X0, $X1);
	my ($Qstart, $Qend) = sort { $a <=> $b } ($X2, $X3);
	my $Strand = (($X0 < $X1) == ($X2 < $X3)) ? '+' : '-';
    print $OUT join("\t", $Rchr, $Rstart, $Rend, $Qchr, $Qstart, $Qend, $Strand, "NA", "NA"), "\n";
}

close $IN;
close $OUT;
print"--OK!--\n";