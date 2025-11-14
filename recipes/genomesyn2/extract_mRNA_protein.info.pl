#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use File::Basename;

# 默认变量
my $gff_file;
my $fasta_file;
my $output_path = './';
my $help;

# 命令行参数解析
GetOptions(
    "gff=s" => \$gff_file,
	"genome=s" => \$fasta_file,
	"outdir=s" => \$output_path,
    "help|h" => \$help,
) or die "Error in command line arguments.\n";

# 帮助信息
if ($help or not $gff_file or not $fasta_file) {
    print <<"USAGE";
Usage:
  perl extract_mRNA_protein.info.pl --genome <genome.fa> --gff <gene.gff3>

Description:
  This script extracts the first mRNA ID (or Name), start, end, and strand (+/-)
  from a GFF3 annotation file. It also generates protein sequences for the selected
  mRNAs from the provided genome FASTA file.

Options:
  --gff <file>      Input GFF3 annotation file (required)
  --genome <file>   Input genome FASTA file (required)
  -h, --help        Show this help message

Output:
  <prefix>.bed       mRNA coordinates (ID, start, end, strand) for mRNAs ending with .1 or -1
  <prefix>.list      List of selected mRNA IDs
  <genome_prefix>.protein.fa  Protein sequences of the selected mRNAs
  <genome_prefix>.protein.all.fa  All protein sequences extracted from genome (temporary, deleted after filtering)

Example:
  perl extract_mRNA_protein.info.pl --genome genome.fa --gff gene.gff3
USAGE
    exit;
}
	# 如果目录不存在,则创建它,并检验是否创建成功
	unless (-d $output_path) {
		print "📁 Directory '$output_path' does not exist. Creating it now...\n";
		system("mkdir -p \"$output_path\"");
		die "Directory '$output_path' does not exist and could not be created!\n" unless -d $output_path;
	}
my $prefix1 = basename($gff_file);
my $prefix_g = basename($fasta_file);
$prefix_g =~ s/\.[^.]+$//;
my $genome_id = $prefix_g . '.genome_id.txt';
my $gff_file_gai = 'filter.' . $prefix1;
$prefix1 =~ s/\.[^.]+$//;
my $output1 = $prefix1 . '.bed';
my $output2 = $prefix1 . '.list';
if($output_path ne './'){
	$genome_id = File::Spec->catfile($output_path, $genome_id);
	$gff_file_gai = File::Spec->catfile($output_path, $gff_file_gai);
	$output1 = File::Spec->catfile($output_path, $output1);
	$output2 = File::Spec->catfile($output_path, $output2);
}
# 生成染色体的ID列表文件
if (!-e $genome_id) {
	system("seqkit seq -n $fasta_file > $genome_id") == 0
		or die "Failed to run seqkit: $!";
} else {
	print "⚠ $genome_id already exists, skipping seqkit(seqkit seq -n $fasta_file > $genome_id).\n";
}
# 提取基因组有的染色体ID的基因注释信息，避免gffread报错[gff3文件有scaffold但基因组fatsa没有时，gffread会报错]
if (!-e $gff_file_gai) {
	system("grep -Ff $genome_id $gff_file > $gff_file_gai") == 0
		or die "Failed to run grep: $!";
} else {
	print "⚠ $gff_file_gai already exists, skipping grep(grep -Ff $genome_id $gff_file > $gff_file_gai).\n";
}
# 打开文件
open(my $IN, "<", $gff_file_gai) or die "Cannot open $gff_file_gai: $!\n";
open(my $OUT1, ">", $output1) or die "Cannot open $output1: $!";
open(my $OUT2, ">", $output2) or die "Cannot open $output2: $!";
# 解析GFF文件，提取mRNA信息
while (<$IN>) {
	chomp;
	next if /^#/;  # 跳过注释行
	my @cols = split(/\t/, $_);
	next unless $cols[2] eq "mRNA";  # 只处理 mRNA 行
	my ($chr, $start, $end, $strand) = @cols[0,3,4,6];
	my ($id) = $cols[8] =~ /Name=([^;]+)/;
	$id ||= ($cols[8] =~ /ID=([^;]+)/)[0];  # 如果没有Name则用ID
	# 只输出以 .1 或 -1 结尾的 mRNA
	if ($id and $id =~ /(?:\.1|-1)$/) {
		print $OUT1 "$id\t$chr\t$start\t$end\t$strand\n";
		print $OUT2 "$id\n";
	}
}
close $IN;
close $OUT1;
close $OUT2;

my $prefix2 = basename($fasta_file);
$prefix2 =~ s/\.[^.]+$//;
my $output3 = $prefix2 . '.protein.all.fa';
my $output4 = $prefix2 . '.protein.first.fa';
my $output5 = $prefix2 . '.protein.fa';
if($output_path ne './'){
	$output3 = File::Spec->catfile($output_path, $output3);
	$output4 = File::Spec->catfile($output_path, $output4);
	$output5 = File::Spec->catfile($output_path, $output5);
}
# 生成所有蛋白序列文件
if (!-e $output3) {
	system("gffread $gff_file_gai -g $fasta_file -y $output3") == 0
		or die "Failed to run gffread: $!";
} else {
	print "⚠ $output3 already exists, skipping gffread.\n";
}
# 提取第一条转录本的蛋白序列
if (!-e $output4) {
	system("seqkit grep -i -f $output2 $output3 > $output4") == 0
		or die "Failed to run seqkit grep: $!";
} else {
	print "⚠ $output4 already exists, skipping seqkit grep.\n";
}

# 检查输出文件是否存在
if (-e $output5) {
    print "⚠️  Warning: File '$output5' already exists. Deleting old file...\n";
    unlink $output5 or warn "Cannot remove $output5: $!";
}
# # 确认文件已删除后,删除序列中除最后一个外的所有其他位置含'.'的序列,并将最后一个位置的'.'改成'*'
if (!-e $output5) {
	open(my $OUT4, "<", $output4) or die "Cannot open $output4: $!\n";
	open(my $OUT5, ">", $output5) or die "Cannot open $output5: $!";
	my $header = '';
	my $seq = '';

	sub flush_seq {
		my ($h, $s) = @_;
		return unless $h;    # nothing to print on first call
		# remove whitespace/newlines in sequence (should be continuous)
		$s =~ s/\s+//g;
		# body = seq except last char (if seq non-empty)
		my $body = length($s) ? substr($s, 0, length($s)-1) : '';
		# 如果 body 中包含 '.' 则跳过该序列
		unless ($body =~ /\./) {
			print $OUT5 $h, "\n";
			# 按 60 长度折行
			$s =~ s/(.{1,60})/$1\n/g;
			$s =~ s/\./\*/g;
			print $OUT5 $s;
		}
	}

	while (<$OUT4>) {
		chomp;
		if (/^>/) {
			flush_seq($header, $seq) if $header;
			$header = $_;
			$seq = '';
		} else {
			$seq .= $_;
		}
	}
	# flush last
	flush_seq($header, $seq);
	close $OUT4;
	close $OUT5;
}

# 删除临时文件
if (-e $output2) {
	unlink $output2 or warn "Cannot remove $output2: $!";
}
if (-e $output3) {
	unlink $output3 or warn "Cannot remove $output3: $!";
}
if (-e $output4) {
	unlink $output4 or warn "Cannot remove $output4: $!";
}
if (-e $genome_id) {
	unlink $genome_id or warn "Cannot remove $genome_id: $!";
}
if (-e $gff_file_gai) {
	unlink $gff_file_gai or warn "Cannot remove $gff_file_gai: $!";
}

print "✅ Extraction completed successfully.\n";
print "Output files:\n";
print "  Coordinates: $output1\n";
print "  Protein sequences: $output5\n";
#./gff2bed.pl 1.MH63.gene.gff3 > 1.MH63.mRNA.bed
#awk '{print$1}' 1.MH63.mRNA.bed > 1.MH63.mRNA.txt
#gffread 1.MH63.gene.gff3 -g 1.MH63RS3.fasta -y 1.MH63RS3.proteins.fa
#seqkit grep -i -f 1.MH63.mRNA.txt 1.MH63RS3.proteins.fa > 1.MH63RS3.proteins2.fa
