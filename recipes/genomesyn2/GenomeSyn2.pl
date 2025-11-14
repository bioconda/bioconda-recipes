#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Bio::SeqIO;
use Cwd 'abs_path';
use File::Spec;
use Data::Dumper;
use FindBin qw($Bin);
use File::Basename;
use SVG;

my $dotplot;
# 设置默认处理可选参数[anno_info:no],[optional_parameter:no],[color_setup:no],[centromere_info:no],[telomere_info:no]
my $skip_anno_info = 0;
my $skip_opt_par = 0;
my $skip_color_setup = 0;
my $skip_centromere_info = 0;
my $skip_telomere_info = 0;
my $skip_region_info = 0;
# print "Script is running from: $Bin\n";
my $Run_GenomeSyn2   = File::Spec->catfile($Bin, 'GenomeSyn2.pl');
my $Run_mummer   = File::Spec->catfile($Bin, 'run_mummer.sh');
my $Run_minimap2 = File::Spec->catfile($Bin, 'run_minimap2.sh');
my $Run_blastp   = File::Spec->catfile($Bin, 'run_blastp.sh');
my $Run_mmseq2   = File::Spec->catfile($Bin, 'run_mmseqs.sh');
my $Run_diamond  = File::Spec->catfile($Bin, 'run_diamond.sh');
my $Run_protein  = File::Spec->catfile($Bin, 'extract_mRNA_protein.info.pl');
my $Run_pep2tsv  = File::Spec->catfile($Bin, 'merge_synteny_info.pl');
my $thread_software=1;
my @genome_path;
my @coords_path;
my %hash_Ginfo;
my %hash_syninfo;
my %hash_legend;

my %hash_chrGAI;
my %hash_read_chr_order;
my %hash_match_best;
my %hash_match_best_num;
my %hash_inversion;
my %aligned_order;
my %chr_orient;
my @arr_ref_chrname;
my $syntent_type = 'curve';#curve, line
my $scale = 0;
my $scale2 = 0;
my $mergin = 25;
my $SVG_main = 200;
my $SVG2_main = 300;
my $SVG_x_top = $mergin;
my $SVG_x_bottom = $mergin;
my $SVG_x_left = $mergin;
my $SVG_x_right = $mergin;
my $ChrHight = 5;
my $Chrtop = 0;
my $Chrdottom = 0;
my $Chrcolor = '#FF0000';
my $synteny_color = '#DFDFE1';
my $inversion_color = '#E56C1A';
my $translocation_color = '#EFCF48';
my $translocation2_color = '#A1BF85';
my $Chropacity = 1;
my $Gname_max_len = 0;
my $chrname_max_len = 0;
my $synteny_height = $ChrHight * 5;
my $chr_gap_height = $ChrHight * 5;
my $SVG_x = $SVG_x_left;
my $SVG_y = $SVG_x_top;
my @default_color = (
	'#39A5D6', '#43A98C', '#B8D891', '#528ABA', '#7ABCD8',
	'#5A9143', '#2E8B57', '#66CDAA', '#4682B4', '#6CA6CD',
	'#8FBC8F', '#FFA07A', '#FF7F50', '#FFD700', '#FF69B4',
	'#CD5C5C', '#8B008B', '#800080', '#20B2AA', '#00CED1',
	'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd',
	'#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf',
	'#393b79', '#637939', '#8c6d31', '#843c39', '#7b4173',
	'#3182bd', '#e6550d', '#31a354', '#756bb1', '#636363'
);
my $n_colors = scalar(@default_color);

#my $default_optional_parameter = {
my %optional_parameter = (
    'genome_height'     => 3,
    'synteny_height'    => 30,
    'scale_ratio'       => 1000,
    'fontsize'          => 12,
    'coverage_rate_min' => 0.9,
    'synteny_min'       => 1000,
    'synteny_linetype'  => 'curve',
    'highlight_synteny' => 'none',
    'region_list'       => 'none',
);

my %color_setup = (
    'synteny_color'       => 3,
    'inversion_color'     => 30,
    'duplication_color'   => 1000,
    'translocation_color' => 12,
	'chr_color_list'      => 'none',
	'synteny_color_list'  => 'none',
	'chr_color'           => 'no', 
	'synteny_color'       => 'no',
);
my $centromere_info = 'none';
my $centromere_file = '';
my $telomere_file = '';
my %telomere_info = (
    'telomere_list'  =>  'none',
	'telomere_color' => '#441680',
	'opacity'        => '100%',
);

my %anno_info = (
    'anno_name' => 'none',
    'anno_color' => 'none',
    'anno_type' => 'none',
    'anno_pasition' => 'top',
    'anno_height' => '10',
    'min_value' => 'none',
    'max_value' => 'none',
    'anno_window' => 'none',
    'opacity' => '100%',
    'file_type' => 'none',
    'anno_list' => 'none',
);

my ($help, $version, $conf_info, $anno_info2, $man, $path, $output, $align, $list, $outdir, $vcf);
my ($density, $identity);
my $SNPcolor_list = '';
my $bin_size = 10_000;
my $prefix = '';
my $genome_pathX = '';
my $gff_pathX = '';
my $type_priority = 'unite';#density,identity,unite
#density----亲缘远-----以"SNP密度"为主，缺失时用一致性补
#identity------亲缘近-----以"SNP一致性"为主，缺失时用密度补
#unite---关系不明----取两者交集显示区间来源
#my $reference = 'NA';


# 所有需要参数的选项和对应的用法说明
my %option_usage = (
    '--align'  => "\n  --align          Specifies the alignment software to be used: <mummer/minimap2/blastp/mmseqs/diamond>\n"
				. "Usage:\n  1) $0 --align mummer   --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  2) $0 --align minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  3) $0 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  4) $0 --align mmseqs --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  5) $0 --align diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n",
    '--genome'  => "\n  --genome   <dir> Path to the directory containing one or more genome FASTA files\n"
				. "                   Filenames should be preprocessed to start with an Arabic numeral followed by a dot (e.g., 1.G1.fa, 2.G2.fa).\n"
				. "                   The program will sort the files numerically for downstream alignment and visualization.\n"
				. "Usage:\n  1) $0 --align mummer   --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  2) $0 --align minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  3) $0 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  4) $0 --align mmseqs --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  5) $0 --align diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n",
    '--gene'  => "\n  --gene     <dir> Path to the directory containing gene annotation files corresponding to the genomes\n"
				. "                   Filenames should be preprocessed to start with an Arabic numeral followed by a dot (e.g., 1.G1.gff3, 2.G2.gff3).\n"
				. "                   The program will sort the files numerically for downstream alignment and visualization.\n"
				. "Usage:\n  1) $0 --align mummer   --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  2) $0 --align minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  3) $0 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  4) $0 --align mmseqs --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  5) $0 --align diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n",
    '--outdir'  => "\n  --outdir   <dir> Specify the output directory for alignment result files\n"
				. "Usage:\n  1) $0 --align mummer   --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  2) $0 --align minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  3) $0 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  4) $0 --align mmseqs --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  5) $0 --align diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n",
    '--thread'  => "\n  --thread   <int> Number of threads to use for parallel processing (default: 1)\n"
				. "Usage:\n  1) $0 --align mummer   --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  2) $0 --align minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30\n"
                . "  3) $0 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  4) $0 --align mmseqs --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n"
                . "  5) $0 --align diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30\n",
    '--vcf'  => "\n  --vcf      <vcf> Input VCF file containing SNP genotypes\n"
				. "Usage:\n  1) $0 --vcf ./parents.progeny.snps.genotype.vcf --bin 50000\n",
    '--bin'  => "\n  --bin      <int> Bin size (genomic window) to calculate SNP density and SNP identity\n"
				. "Usage:\n  1) $0 --vcf ./parents.progeny.snps.genotype.vcf --bin 50000\n",
    '--identity'  => "\n  --identity <bed> BED file containing precomputed SNP identity information across bins\n"
				. "Usage:\n  1) $0 --identity ./SNP_identity.50Kb.bed --density ./SNP_density.50Kb.bed\n",
    '--density'  => "\n  --density  <bed> BED file containing precomputed SNP density information across bins\n"
				. "Usage:\n  1) $0 --identity ./SNP_identity.50Kb.bed --density ./SNP_density.50Kb.bed\n",
    '--type'  => "\n  --type           Type of input data: <fa|prot|anno>\n"
				. "                   fa    - genome sequences or chromosome length (FASTA/bed)\n"
				. "                   prot  - protein sequences (FASTA)\n"
				. "                   anno  - genome annotation files (GFF/GTF/bed)\n"
				. "Usage:\n  1) $0 --type fa --path ./genome_path/ --out genome.info.tsv\n"
				. "  2) $0 --type prot --path ./protein_path/ --out protein.info.tsv\n"
				. "  3) $0 --type anno --path ./your_path/ --out anno.info.tsv\n",
    '--path'  => "\n  --path     <dir> Generate a file named 'X.tsv' in the current directory(--out X.tsv), containing absolute\n"
				. "                   paths of all files in the given path\n"
				. "Usage:\n  1) $0 --type fa --path ./genome_path/ --out genome.info.tsv\n"
				. "  2) $0 --type prot --path ./protein_path/ --out protein.info.tsv\n"
				. "  3) $0 --type anno --path ./your_path/ --out anno.info.tsv\n",
    '--out'  => "\n  --out            Set the output file name to be generated\n"
				. "Usage:\n  1) $0 --type fa --path ./genome_path/ --out genome.info.tsv\n"
				. "  2) $0 --type prot --path ./protein_path/ --out protein.info.tsv\n"
				. "  3) $0 --type anno --path ./your_path/ --out anno.info.tsv\n",
    '--anno'  => "\n  --anno           Configuration file for displaying and editing annotation information\n"
				. "Usage:\n  1) $0 --anno ?\n"
				. "  2) $0 --anno ? >> total.conf\n",
    '--conf'  => "\n  --conf           Display and modify the Configuration file\n"
				. "Usage:\n  1) $0 --conf ?\n"
				. "  2) $0 --conf ? > total.conf\n",
);

# 统一检查参数缺失
foreach my $opt (keys %option_usage) {
    for (my $i = 0; $i < @ARGV; $i++) {
        if ($ARGV[$i] eq $opt) {
            if (!defined $ARGV[$i + 1] || $ARGV[$i + 1] =~ /^--/) {
                die "Option $opt requires an argument\n" . $option_usage{$opt};
            }
        }
    }
}
my @ARGV_copy = @ARGV;  # 复制原始ARGV内容，供后续判断
GetOptions(
    'h|help'    => \$help,
    'v|version' => sub { print "$0: version 2.0\n"; exit },
    'm|man'     => \$man,
    'conf=s'  => \$conf_info,
    'anno=s'    => \$anno_info2,
	'path=s'  =>  \$path,
	'out=s'   =>  \$output,
	'outdir=s'  => \$outdir,
	'align=s' =>  \$align,
	'vcf=s'   =>  \$vcf, 
	'bin=s'   =>  \$bin_size,
	'prefix=s'=>  \$prefix,
	'density=s' => \$density,
	'identity=s' => \$identity,
	'color_list=s' => \$SNPcolor_list,
	'type=s' => \$type_priority,
	'genome=s' => \$genome_pathX,
	'gene=s' => \$gff_pathX,
	't|thread=s' => \$thread_software,
) or die "Usage: $0 --help\n";

# 如果请求了 --man，调用 perldoc 显示完整手册
if ($man) {
    exec("perldoc", $0) or die "Failed to exec perldoc: $!";
}
# --anno help => 输出默认注释配置
if (defined $anno_info2 && (($anno_info2 eq 'help')||($anno_info2 eq '?'))) {
    print <<'END_ANNO';

[anno_info:no]
anno_number=[1,2,3,4,5,6,7]
anno_name=[PAV,SNP,TE,GC Content,Gypsy,Copia,Gene density]
anno_color=['#5FB6DE','#0000FF','#3774B9','#000000','#00FF00','#F5F57A','#368F5C']
anno_type=[rectangle,barplot,barplot,lineplot,lineplot,lineplot,heatmap]
anno_position=[top,top,bottom,top,bottom,bottom,middle]
anno_height=[5,5,5,5,5,5,5]
min_max_value=[normal,auto,normal,0.4:0.5,normal,normal,normal]
anno_window=[none,none,100000,none,100000,100000,100000]
opacity=[50%,100%,100%,100%,100%,100%,100%]
file_type=[bed,bed,gff3,bed,gff3,gff3,gff3]
filter_type=[none,none,none,none,none,none,gene]
anno_list=[PAV.info.tsv,SNP.info.tsv,TE.info.tsv,GC.info.tsv,Gypsy.info.tsv,Copia.info.tsv,gene.info.tsv]
END_ANNO
    exit;
}

# -c,--conf help => 输出默认配置
if (defined $conf_info && (($conf_info eq 'help')||($conf_info eq '?'))) {
    print <<'END_CONF';
[genome_info]
# gonomes_filetype = (fasta/bed)
gonomes_filetype = bed
gonomes_list = chr_length.info.tsv

[synteny_info]
# line_type = (curve/line)
line_type = curve
synteny_list = synteny.info.tsv

[save_info]
# figure_type = (.svg/.pdf)
figure_type = pdf
savefig1 = GenomeSyn2.figure1.pdf
savefig2 = GenomeSyn2.figure2.pdf

[centromere_info:no]
centromere_list=centromere.info.tsv

[telomere_info:no]
telomere_list=telomere.info.tsv
telomere_color=#441680
opacity=100%

[show_region:no]
region = R:Chr10_R:23,362,471-23,380,557
gene_list = gene.info.tsv
END_CONF
    exit;
}

# 检查只允许的参数，否则输出帮助并退出
my %valid_opts = (
    '--help' => 1, '-h' => 1, '--man' => 1, '-m' => 1, '--version' => 1, '-v' => 1,
	'--align' => 1, '--genome' => 1, '--gene' => 1, '--outdir' => 1, '--thread' => 1,
	'--vcf'  => 1, '--bin'   => 1, '--identity'  => 1, '--density'   => 1,
	'--type' => 1, '--path' => 1, '--out' => 1,
    '--anno' => 1, '--conf' => 1,
);

# --help 功能if (!@ARGV)
#if ( $help ||(!@ARGV) || ($ARGV[0] // '') eq '?') {
if ($help || scalar(@ARGV_copy) == 0) {
    print_usage();
    exit(1);
}
# 检查3种允许的参数组合，且参数值存在且合理
my $valid = 0;
my $Align_switch=0;
########################################
# $valid = 1; #####--path，--out
# GenomeSyn2 --path ./fa_data/ --out genomes.info.tsv/pep.info.tsv
########################################
# $valid = 2; ##### --align，--genome，--outdir, --thread
# GenomeSyn2 --align mummer/minimap2 -genome ./genome_path/ --outdir ./mummer/ --thread 30
########################################
# $valid = 2; ##### --align，--genome，--gene, --outdir, --thread
# GenomeSyn2 --align blastp/mmseqs/diamond ./genome_path/ --gene ./gene_data/ --outdir ./mmseqs/ --thread 30
########################################
# $valid = 3; ##### --conf
# GenomeSyn2 --conf total.conf
########################################
# $valid = 4; ##### --vcf, --out, --outdir, --bin, --prefix
# GenomeSyn2 --vcf input.vcf
# GenomeSyn2 --vcf input.vcf --out GenomeSyn2.vcf.pdf --outdir ./vcf_temp/ --prefix Parent_identity -bin 1_000_000
########################################
# $valid = 4; ##### --density, --identity, --out, --outdir, --bin, --prefix
# GenomeSyn2 --vcf input.vcf
# GenomeSyn2 --density SNP_density.500Kb.bed --identity SNP_identity.500Kb.bed --out GenomeSyn2.vcf.pdf --outdir ./vcf_temp/ --color_list '#1f77b4,#ff7f0e,#ff7f0e,#d62728'
########################################

# 主模式标志
my $mode_path = defined $path && defined $output;
#my $mode_align = defined $align && defined $list && defined $output && defined $outdir;
my $mode_align_DNA = defined $align && defined $genome_pathX && defined $outdir;
my $mode_align_pep = defined $align && defined $genome_pathX && defined $gff_pathX && defined $outdir;
my $mode_conf = defined $conf_info;
my $mode_vcf  = defined $vcf;
my $mode_snp  = (defined $identity || defined $density);

# 不允许与任何其它主模式共存的“排他变量”，**排除当前主模式**
my $has_exclusive_path  = defined $align && defined $list && defined $outdir
                        && defined $conf_info && defined $anno_info2 && defined $vcf && defined $bin_size && defined $prefix&&defined $identity && defined $density;
#my $has_exclusive_align = defined $path && defined $conf_info && defined $anno_info2 && defined $vcf && defined $bin_size && defined $prefix;
my $has_exclusive_align2 = defined $output && defined $list && defined $path && defined $conf_info && defined $anno_info2 && defined $vcf && defined $bin_size && defined $prefix;
my $has_exclusive_conf  = defined $path && defined $output && defined $align && defined $list && defined $outdir && defined $anno_info2 && defined $vcf && defined $bin_size && defined $prefix;
my $has_exclusive_vcf   = defined $path && defined $align && defined $list && defined $conf_info && defined $anno_info2;
my $has_exclusive_snp   = defined $path && defined $align && defined $list && defined $outdir && defined $conf_info && defined $anno_info2 && defined $vcf && defined $bin_size && defined $prefix;

my $valid_vcf = 0;
# 选择 valid
if ($mode_path && !$has_exclusive_path) {$valid = 1;}
elsif ($mode_align_DNA && !$has_exclusive_align2) {$valid = 2;}
elsif ($mode_align_pep && !$has_exclusive_align2) {$valid = 2;}
elsif ($mode_conf && !$has_exclusive_conf) {$valid = 3;}
elsif ($mode_vcf && !$has_exclusive_vcf) {$valid = 4;$valid_vcf = 1;}
elsif ($mode_snp && !$has_exclusive_snp) {$valid = 4;}
#elsif ($mode_align && !$has_exclusive_align) {
#    $valid = 5;
#}
$type_priority = lc($type_priority);

unless ($valid) {
	print"$valid\n";
    print STDERR "Invalid or incomplete parameter set.\n";
    print_usage();
    exit(1);
}
# 如果程序走到这里，参数通过检查，可以正常执行你的主程序逻辑
# print "Parameters valid, proceeding...\n";
# 这里添加你的程序逻辑代码

if($valid == '1') {
	# 检查目录是否存在
	die "Directory '$path' does not exist!\n" unless -d $path;
	# 打开目录
	opendir(my $dh, $path) or die "Cannot open directory $path: $!";
	if (defined $type_priority) {
		if($type_priority =~ /^(fa|fasta|fas|fna|tsv|txt)$/i) {
			# 读取文件并筛选出以数字打头的 .fa 或 .fasta 或.tsv 或.txt 文件
			my @files = grep { /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|bed|tsv|txt)$/i } readdir($dh);
			closedir($dh);
			# 排序文件（按数字编号）
			@files = sort {
				($a =~ /^(\d+)/)[0] <=> ($b =~ /^(\d+)/)[0]
			} @files;
			# 打开输出文件句柄
			open(my $out_fh, ">", $output) or die "Cannot open output file '$output': $!";
			# 打印表头
			print $out_fh "#number\tfile\tgenome_name\ttags\n";
			# 输出每一行内容
			my $count = 0;
			foreach my $file (@files) {
				my $full_path = abs_path(File::Spec->catfile($path, $file));
				# 提取 genome name，如 1.A.genome.fa 提取 A
				my ($genome_name0) = $file =~ /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|bed|tsv|txt)$/;
				my ($genome_name) = split(/\./, $genome_name0, 2);
				my $outcolor = $default_color[$count%$n_colors];
				my $outtags = "height:5;opacity:0.8;color:'" . "$outcolor" ."';";
				$count++;
				#print join("\t", $count, $full_path, $genome_name, $outtags), "\n";
				print $out_fh join("\t", $count, $full_path, $genome_name, $outtags), "\n";
			}
			close $out_fh;
			# 在终端提示
			print "✅ Output file has been generated: $output\n";
		}
		elsif($type_priority =~ /^(prot|pep|protein)$/i) {
			#
		}
		elsif($type_priority =~ /^(anno|aoontation)$/i) {
			# 读取文件
			my @files = grep { /^\d+\.(.+?)\.(?:gff3|gtf|gff|bed|tsv|txt)$/i } readdir($dh);
			closedir($dh);
			# 排序文件（按数字编号）
			@files = sort {
				($a =~ /^(\d+)/)[0] <=> ($b =~ /^(\d+)/)[0]
			} @files;
			# 打开输出文件句柄
			open(my $out_fh, ">", $output) or die "Cannot open output file '$output': $!";
			# 打印表头
			print $out_fh "#number\tfile_path\n";
			# 输出每一行内容
			my $count = 0;
			foreach my $file (@files) {
				my $full_path = abs_path(File::Spec->catfile($path, $file));
				$count++;
				print $out_fh join("\t", $count, $full_path), "\n";
			}
			close $out_fh;
			# 在终端提示
			print "✅ Output file has been generated: $output\n";
		}
		if (open(my $in_fh, "<", $output)) {
			print "\n📄 File content of '$output':\n";
			print "-----------------------------------\n";
			while (my $line = <$in_fh>) {
				print $line;
			}
			close $in_fh;
			print "-----------------------------------\n";
		}
		else {warn "⚠️ Cannot open '$output' for reading: $!";}
	}
}
elsif($valid == '2') {
	# 大小写不敏感[mummer/minimap2/blastp/mmseqs/diamond]
	my $align_lc = lc($align);
	# 如果目录不存在,则创建它,并检验是否创建成功
	unless (-d $outdir) {
		system("mkdir -p \"$outdir\"");
		die "Directory '$outdir' does not exist and could not be created!\n" unless -d $outdir;
	}
	my $fa_bed_path = $outdir . '/fa_bed/';
	unless (-d $fa_bed_path) {
		system("mkdir -p \"$fa_bed_path\"");
		die "Directory '$fa_bed_path' does not exist and could not be created!\n" unless -d $fa_bed_path;
	}
	my $align_path = $outdir . '/' . $align_lc;
	unless (-d $align_path) {
		system("mkdir -p \"$align_path\"");
		die "Directory '$align_path' does not exist and could not be created!\n" unless -d $align_path;
	}
	# Remove trailing slash if it exists
	$outdir =~ s/\/$//;
	if(($align_lc eq 'mummer')or($align_lc eq 'minimap2'))
	{
		my $output_genome = 'genomes.info.tsv';
		my $output_chr_len = 'chr_length.info.tsv';
		my $output_synteny = 'synteny.info.tsv';
		# 检查目录是否存在
		die "Directory '$genome_pathX' does not exist!\n" unless -d $genome_pathX;
		# 打开目录
		opendir(my $dh, $genome_pathX) or die "Cannot open directory $genome_pathX: $!";
		# 读取文件并筛选出以数字打头的 .fa 或 .fasta 或.tsv 或.txt 文件
		my @files = grep { /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|faa|bed|tsv|txt)$/i } readdir($dh);
		closedir($dh);
		# 排序文件（按数字编号）
		@files = sort {
			($a =~ /^(\d+)/)[0] <=> ($b =~ /^(\d+)/)[0]
		} @files;
		# 打开输出文件句柄
		open(my $out_fh, ">", $output_genome) or die "Cannot open output file '$output_genome': $!";
		open(my $out_fh2, ">", $output_chr_len) or die "Cannot open output file '$output_chr_len': $!";
		# 打印表头
		print $out_fh "#number\tfile\tgenome_name\ttags\n";
		print $out_fh2 "#number\tfile\tgenome_name\ttags\n";
		# 输出每一行内容
		my $count = 0;
		foreach my $file (@files) {
			my $prefixX = $file;
			$prefixX =~ s/\.[^.]+$//;
			#my $chr_len_name = $prefixX . '.bed';
			my $outdir_fabed = $fa_bed_path . $prefixX . '.bed';
			my $chr_len_path = abs_path("$outdir_fabed");
			my $full_path = abs_path(File::Spec->catfile($genome_pathX, $file));
			open(my $out_fh3, ">", $chr_len_path) or die "Cannot open output file '$chr_len_path': $!";
			my $fasta_file = $full_path;
			# 创建 SeqIO 对象（自动识别 fasta 格式）
			my $seqio = Bio::SeqIO->new(-file => $fasta_file, -format => 'fasta');
			my %hash_chr_sort;
			# 遍历每条序列
			while (my $seq = $seqio->next_seq) {
				my $id   = $seq->id;      # 染色体ID（>后面的第一个单词）
				my $len  = $seq->length;  # 序列长度
				my $merge_chrinfo = "$id\t$len\t$id";
				$hash_chr_sort{$id} = $merge_chrinfo;
				#print $out_fh3 "$merge_chrinfo\n";
			}
			foreach my $key_chr(sort keys %hash_chr_sort)
			{
				my $merge_chrinfo = $hash_chr_sort{$key_chr};
				print $out_fh3 "$merge_chrinfo\n";
				print "$merge_chrinfo\n";
			}
			close $out_fh3;
			# 提取 genome name，如 1.A.genome.fa 提取 A
			my ($genome_name0) = $file =~ /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|faa|bed|tsv|txt)$/;
			my ($genome_name) = split(/\./, $genome_name0, 2);
			my $outcolor = $default_color[$count%$n_colors];
			my $outtags = "height:5;opacity:0.8;color:'" . "$outcolor" ."';";
			$count++;
			#print join("\t", $count, $full_path, $genome_name, $outtags), "\n";
			print $out_fh join("\t", $count, $full_path, $genome_name, $outtags), "\n";
			print $out_fh2 join("\t", $count, $chr_len_path, $genome_name, $outtags), "\n";
		}
		close $out_fh;
		close $out_fh2;
		# 在终端提示
		print "✅ Output file has been generated: $output_genome\n";
		print "✅ Output file has been generated: $output_chr_len\n";
		if (open(my $in_fh, "<", $output_genome)) {
			print "\n📄 File content of '$output_genome':\n";
			print "-----------------------------------\n";
			while (my $line = <$in_fh>) {
				print $line;
			}
			close $in_fh;
			print "-----------------------------------\n";
		}
		else {warn "⚠️ Cannot open '$output_genome' for reading: $!";}
		open(my $in, "<", $output_genome) or die "Cannot open file $output_genome: $!";
		my @genome_names;
		# 读取文件内容
		while (<$in>) {
			chomp;
			next if /^#/ || /^\s*$/;  # 跳过注释或空行

			my @cols = split /\t/;
			push(@genome_names, $cols[2]);  # 第3列genome_name
			push(@genome_path, $cols[1]);   # 第2列genome_path
		}
		close($in);
		# 打开输出文件句柄
		open(my $out_fh3, ">", $output_synteny) or die "Cannot open output file '$output_synteny': $!";
		# 打印 synteny.info.tsv 表头
		print $out_fh3 "#number\tref_file\tquery_file\talign_file\n";
		# 遍历相邻的 genome_name，配对生成输出
		for (my $i = 0; $i < $#genome_names; $i++) {
			my $j = $i + 1;
			my $ref   = $genome_names[$i];
			my $query = $genome_names[$i + 1];
			my $genomeSeq1 = $genome_path[$i];
			my $genomeSeq2 = $genome_path[$i + 1];
			my $align_name = '';
			if($align_lc eq 'mummer'){$align_name = "${j}.${ref}vs${query}.mummer.tsv";}
			elsif($align_lc eq 'minimap2'){$align_name = "${j}.${ref}vs${query}.minimap2.tsv";}
			my $full_path = abs_path("$align_path/$align_name");
			printf $out_fh3 "%d\t%s\t%s\t%s\n", $j, $genomeSeq1, $genomeSeq2, $full_path;
			push(@coords_path, $full_path);
		}
		close $out_fh3;
		# 在终端提示
		print "✅ Output file has been generated: $output_synteny\n";
		# 串联循环提交比对任务（@genome_path 有 N+1 个，循环 N 次）
		for (my $i = 0; $i < $#genome_path; $i++) {
			my $j = $i + 1;
			my $genomeSeq1 = $genome_path[$i];
			my $genomeSeq2 = $genome_path[$i + 1];
			my $PREFIX1    = $j . '.' .$genome_names[$i] . 'vs' . $genome_names[$i + 1];
			my $genomeName1 = $genome_names[$i];
			my $genomeName2 = $genome_names[$i + 1];
			$PREFIX1 = abs_path("$align_path/$PREFIX1");
			print "🧬 Running alignment [$align_lc] for $genome_names[$i] vs $genome_names[$i+1]...\n";
			if ($align_lc eq 'mummer') {
				# Usage: ./run_mummer.sh <ref_file> <query_file> <index_name> [threads_number]
				print"$Run_mummer $genomeSeq1 $genomeSeq2 $PREFIX1 $thread_software\n";
				system("$Run_mummer $genomeSeq1 $genomeSeq2 $PREFIX1 $thread_software");
			}
			elsif ($align_lc eq 'minimap2') {
				# Usage: ./run_minimap2.sh <ref_file> <query_file> <index_name> [threads_number]
				print"$Run_minimap2 $genomeSeq1 $genomeSeq2 $PREFIX1 $thread_software\n";
				system("$Run_minimap2 $genomeSeq1 $genomeSeq2 $PREFIX1 $thread_software");
			}
			else {
				die "❌ Unknown alignment method: $align\n";
			}
		}
		my $output_conf = 'total.conf';
		
		if (-e $output_conf) {
			print "⚠️  Warning: File '$output_conf' already exists. Deleting old file...\n";
			unlink $output_conf or warn "Cannot remove $output_conf: $!";
		}
		system("$Run_GenomeSyn2 --conf ? >> total.conf");
		system("$Run_GenomeSyn2 --conf total.conf");
	}
	elsif(($align_lc eq 'blastp')or($align_lc eq 'mmseqs')or($align_lc eq 'diamond'))
	{
		my $output_genome = 'genomes.info.tsv';
		my $output_chr_len = 'chr_length.info.tsv';
		my $output_synteny = 'synteny.info.tsv';
		# 检查目录是否存在
		die "Directory '$genome_pathX' does not exist!\n" unless -d $genome_pathX;
		die "Directory '$gff_pathX' does not exist!\n" unless -d $gff_pathX;
		# 打开目录
		opendir(my $dh, $genome_pathX) or die "Cannot open directory $genome_pathX: $!";
		opendir(my $dh_gff, $gff_pathX) or die "Cannot open directory $gff_pathX: $!";
		# 读取文件并筛选出以数字打头的 .fa 或 .fasta 或.tsv 或.txt 文件
		my @files = grep { /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|faa|bed|tsv|txt)$/i } readdir($dh);
		my @files_gff = grep { /^\d+\.(.+?)\.(?:gff3|gff|gtf|bed|tsv|txt)$/i } readdir($dh_gff);
		closedir($dh);
		closedir($dh_gff);
		# 排序文件（按数字编号）
		@files = sort {
			($a =~ /^(\d+)/)[0] <=> ($b =~ /^(\d+)/)[0]
		} @files;
		@files_gff = sort {
			($a =~ /^(\d+)/)[0] <=> ($b =~ /^(\d+)/)[0]
		} @files_gff;
		my $num_scalar1 =scalar(@files);
		my $num_scalar2 =scalar(@files_gff);
		if($num_scalar1 eq $num_scalar2)
		{
			# 打开输出文件句柄
			open(my $out_fh, ">", $output_genome) or die "Cannot open output file '$output_genome': $!";
			open(my $out_fh2, ">", $output_chr_len) or die "Cannot open output file '$output_chr_len': $!";
			# 打印表头
			print $out_fh "#number\tfile\tgenome_name\ttags\n";
			print $out_fh2 "#number\tfile\tgenome_name\ttags\n";
			# 输出每一行内容
			my $count = 0;
			for(my $i = 0;$i < $num_scalar1; $i++)
			{
				my $genome_file = $files[$i];
				my $gff_file = $files_gff[$i];
				$genome_file = File::Spec->catfile($genome_pathX, $genome_file);
				$gff_file = File::Spec->catfile($gff_pathX, $gff_file);
				system("$Run_protein --genome $genome_file --gff $gff_file --outdir $align_path");
			}
			foreach my $file (@files) {
				my $prefixX = $file;
				$prefixX =~ s/\.[^.]+$//;
				#my $chr_len_name = $prefixX . '.bed';
				my $outdir_fabed = $fa_bed_path . $prefixX . '.bed';
				my $chr_len_path = abs_path("$outdir_fabed");
				my $full_path = abs_path(File::Spec->catfile($genome_pathX, $file));
				open(my $out_fh3, ">", $chr_len_path) or die "Cannot open output file '$chr_len_path': $!";
				my $fasta_file = $full_path;
				my %hash_chr_sort;
				# 创建 SeqIO 对象（自动识别 fasta 格式）
				my $seqio = Bio::SeqIO->new(-file => $fasta_file, -format => 'fasta');
				# 遍历每条序列
				while (my $seq = $seqio->next_seq) {
					my $id   = $seq->id;      # 染色体ID（>后面的第一个单词）
					my $len  = $seq->length;  # 序列长度
					my $merge_chrinfo = "$id\t$len\t$id";
					$hash_chr_sort{$id} = $merge_chrinfo;
					#print $out_fh3 "$id\t$len\t$id\n";
				}
				foreach my $key_chr(sort keys %hash_chr_sort)
				{
					my $merge_chrinfo = $hash_chr_sort{$key_chr};
					print $out_fh3 "$merge_chrinfo\n";
					print "$merge_chrinfo\n";
				}
				close $out_fh3;
				# 提取 genome name，如 1.A.genome.fa 提取 A
				my ($genome_name0) = $file =~ /^\d+\.(.+?)\.(?:fa|fasta|fas|fna|faa|bed|tsv|txt)$/;
				my ($genome_name) = split(/\./, $genome_name0, 2);
				my $outcolor = $default_color[$count%$n_colors];
				my $outtags = "height:5;opacity:0.8;color:'" . "$outcolor" ."';";
				$count++;
				#print join("\t", $count, $full_path, $genome_name, $outtags), "\n";
				print $out_fh join("\t", $count, $full_path, $genome_name, $outtags), "\n";
				print $out_fh2 join("\t", $count, $chr_len_path, $genome_name, $outtags), "\n";
			}
			close $out_fh;
			close $out_fh2;
			# 在终端提示
			print "✅ Output file has been generated: $output_genome\n";
			print "✅ Output file has been generated: $output_chr_len\n";
			if (open(my $in_fh, "<", $output_genome)) {
				print "\n📄 File content of '$output_genome':\n";
				print "-----------------------------------\n";
				while (my $line = <$in_fh>) {
					print $line;
				}
				close $in_fh;
				print "-----------------------------------\n";
			}
			else {warn "⚠️ Cannot open '$output_genome' for reading: $!";}
			open(my $in, "<", $output_genome) or die "Cannot open file $output_genome: $!";
			my @genome_names;
			# 读取文件内容
			while (<$in>) {
				chomp;
				next if /^#/ || /^\s*$/;  # 跳过注释或空行

				my @cols = split /\t/;
				push(@genome_names, $cols[2]);  # 第3列genome_name
				push(@genome_path, $cols[1]);   # 第2列genome_path
			}
			close($in);
			# 打开输出文件句柄
			open(my $out_fh3, ">", $output_synteny) or die "Cannot open output file '$output_synteny': $!";
			# 打印 synteny.info.tsv 表头
			print $out_fh3 "#number\tref_file\tquery_file\talign_file\n";

			# 遍历相邻的 genome_name，配对生成输出
			for (my $i = 0; $i < $#genome_names; $i++) {
				my $j = $i + 1;
				my $ref   = $genome_names[$i];
				my $query = $genome_names[$i + 1];
				my $genomeSeq1 = $files[$i];
				my $genomeSeq2 = $files[$i + 1];
				$genomeSeq1 = basename($genomeSeq1);
				$genomeSeq2 = basename($genomeSeq2);
				$genomeSeq1 =~ s/\.[^.]+$//;
				$genomeSeq2 =~ s/\.[^.]+$//;
				my $proteinSEQ1 = $genomeSeq1 . '.protein.fa';
				my $proteinSEQ2 = $genomeSeq2 . '.protein.fa';
				$proteinSEQ1 = abs_path("$align_path/$proteinSEQ1");
				$proteinSEQ2 = abs_path("$align_path/$proteinSEQ2");
				my $align_name = '';
				if($align_lc eq 'blastp'){$align_name = "${j}.${ref}vs${query}.blastp.tsv";}
				elsif($align_lc eq 'mmseqs'){$align_name = "${j}.${ref}vs${query}.mmseqs.tsv";}
				elsif($align_lc eq 'diamond'){$align_name = "${j}.${ref}vs${query}.diamond.tsv";}
				my $full_path = abs_path("$align_path/$align_name");
				printf $out_fh3 "%d\t%s\t%s\t%s\n", $j, $proteinSEQ1, $proteinSEQ2, $full_path;
				push(@coords_path, $full_path);
			}
			close $out_fh3;
			# 在终端提示
			print "✅ Output file has been generated: $output_synteny\n";
			# 串联循环提交比对任务（@genome_path 有 N+1 个，循环 N 次）
			for (my $i = 0; $i < $#genome_path; $i++) {
				my $j = $i + 1;
				my $genomeSeq1 = $genome_path[$i];
				my $genomeSeq2 = $genome_path[$i + 1];
				my $PREFIX1    = $j . '.' .$genome_names[$i] . 'vs' . $genome_names[$i + 1];
				my $genomeName1 = $genome_names[$i];
				my $genomeName2 = $genome_names[$i + 1];
				$genomeSeq1 = basename($genomeSeq1);
				$genomeSeq2 = basename($genomeSeq2);
				$genomeSeq1 =~ s/\.[^.]+$//;
				$genomeSeq2 =~ s/\.[^.]+$//;
				my $proteinSEQ1 = $genomeSeq1 . '.protein.fa';
				my $proteinSEQ2 = $genomeSeq2 . '.protein.fa';
				$proteinSEQ1 = abs_path("$align_path/$proteinSEQ1");
				$proteinSEQ2 = abs_path("$align_path/$proteinSEQ2");
				my $align_name = '';
				if($align_lc eq 'blastp'){$align_name = "${PREFIX1}.blastp.tsv";}
				elsif($align_lc eq 'mmseqs'){$align_name = "${PREFIX1}.mmseqs.tsv";}
				elsif($align_lc eq 'diamond'){$align_name = "${PREFIX1}.diamond.tsv";}
				my $full_path = abs_path("$align_path/$align_name");
				$PREFIX1 = abs_path("$align_path/$PREFIX1");
				print "🧬 Running alignment [$align_lc] for $genome_names[$i] vs $genome_names[$i+1]...\n";
				my $gene_site1 = $files_gff[$i];
				$gene_site1 =~ s/\.[^.]+$//;
				$gene_site1 = $gene_site1 . '.bed';
				$gene_site1 = abs_path(File::Spec->catfile($align_path, $gene_site1));
				my $gene_site2 = $files_gff[$j];
				$gene_site2 =~ s/\.[^.]+$//;
				$gene_site2 = $gene_site2 . '.bed';
				$gene_site2 = abs_path(File::Spec->catfile($align_path, $gene_site2));
				if ($align_lc eq 'blastp') {
					# Usage: ./run_blastp.sh <query_fasta> <db_fasta> <db_prefix> <output_file> [thread_software]
					$PREFIX1 = $PREFIX1 . '.blast';
					print"$Run_blastp $proteinSEQ2 $proteinSEQ1 $genomeName1 $PREFIX1 $thread_software\n";
					system("$Run_blastp $proteinSEQ2 $proteinSEQ1 $genomeName1 $PREFIX1 $thread_software");
					system("$Run_pep2tsv --align $align_lc --synteny $PREFIX1 --ref $gene_site1 --query $gene_site2 --out $full_path");
				}
				elsif ($align_lc eq 'mmseqs') {
					# Usage: ./run_mmseqs.sh <index_fasta> <target_fasta> <db1_prefix> <db2_prefix> <output_file> [threads_number]
					$PREFIX1 = $PREFIX1 . '.mmseqs.out';
					print"$Run_blastp $proteinSEQ2 $proteinSEQ1 $genomeName1 $PREFIX1 $thread_software\n";
					system("$Run_mmseq2 $proteinSEQ1 $proteinSEQ2 $genomeName1 $genomeName2 $PREFIX1 $thread_software");
					system("$Run_pep2tsv --align $align_lc --synteny $PREFIX1 --ref $gene_site1 --query $gene_site2 --out $full_path");
				}
				elsif ($align_lc eq 'diamond') {
					# Usage: ./run_diamond.sh <query_fasta> <target_fasta> <targetDB_prefix> <output_prefix> [threads_number]
					$PREFIX1 = $PREFIX1 . '.diamond';
					print"$Run_blastp $proteinSEQ2 $proteinSEQ1 $genomeName1 $PREFIX1 $thread_software\n";
					system("$Run_diamond $proteinSEQ2 $proteinSEQ1 $genomeName1 $PREFIX1 $thread_software");
					system("$Run_pep2tsv --align $align_lc --synteny $PREFIX1 --ref $gene_site1 --query $gene_site2 --out $full_path");
				}
				else {
					die "❌ Unknown alignment method: $align\n";
				}
			}
			my $output_conf = 'total.conf';
			
			if (-e $output_conf) {
				print "⚠️  Warning: File '$output_conf' already exists. Deleting old file...\n";
				unlink $output_conf or warn "Cannot remove $output_conf: $!";
			}
			system("$Run_GenomeSyn2 --conf ? >> total.conf");
			system("$Run_GenomeSyn2 --conf total.conf");
		}
	}
}
elsif($valid == '3') {
	# 读取配置文件,并设置成参数大小写不敏感
	my %config = read_config_file($conf_info);
	# 检查必需的参数是否存在[genome_info],[synteny_info],[save_info]
	process_required_params(\%config);
	# 处理配置信息
	# process_config(\%config);
    # 打印配置信息（调试用）
    print_config_summary(\%config);
}
elsif($valid == '4') {
	$Chrtop = $ChrHight * 2;#$ChrHight = 5;
	$Chrdottom = $ChrHight;
	if(!defined $outdir){$outdir = './';}
	unless(-d $outdir){mkdir $outdir or die "Cannot create $outdir: $!";}
	if($prefix ne ''){$prefix = "$prefix" . '.';}
	my $bin_char = num2char($bin_size);
	#$output = 'GenomeSyn2.vcf.pdf';
	#if(!defined $output){$output = "$outdir" . "$prefix" . 'GenomeSyn.' . "$bin_char" . '.pdf';}
	if($valid_vcf == 1)
	{
		my $vcf_out1 = "$outdir" . "$prefix" . 'genotype.out.vcf';
		my $vcf_out2 = "$outdir" . "$prefix" . 'SNP_density.' . "$bin_char" . '.bed';
		my $vcf_out3 = "$outdir" . "$prefix" . 'SNP_identity.' . "$bin_char" . '.bed';
		read_vcf_output($vcf, $vcf_out1, $vcf_out2, $vcf_out3);
		$identity = $vcf_out3;
		$density = $vcf_out2;
	}
	my $countline = 0;
	my (@arr_sample2, @arr_sample);
	my (%contig_len, %sample_color, %sample_index, %SNP_density, %SNP_identity, %sample_color0);
	my (%hash_bin1, %hash_bin2);
	open(my $IN_SNPidentity,  "<", $identity)  or die "Cannot open $identity: $!";
	while (<$IN_SNPidentity>) {
		chomp;
		next if /^\s*$/;  # 可选：跳过空行
		my @cols = split(/\t/, $_);
		$countline++;
		if($countline == 1)
		{
			shift(@cols);shift(@cols);shift(@cols);
			push(@arr_sample2, @cols);
			my $i = 0;
			foreach my $sample (@cols)
			{
				#if($i!=0)
				{
					$sample_index{$i} = $sample;
					#my $j = $i - 1;
					#$sample_color0{$sample} = $default_color[$j%$n_colors];
					$sample_color0{$sample} = $default_color[$i%$n_colors];
					push(@arr_sample,$sample);
				}
				$i++;
			}
			next;
		}
		else
		{
			my $CHR = shift(@cols);
			my $start = shift(@cols);
			my $end = shift(@cols);
			my $i = 0;
			my $bin_SIZE = $end - $start + 1;
			$hash_bin1{$bin_SIZE} += 1;
			foreach my $valueX (@cols)
			{
				my $Sample = $arr_sample2[$i];
				$SNP_identity{$CHR}->{$start}->{$end}->{$Sample} = $valueX;
				$i++;
			}
			$contig_len{$CHR} = $end > ($contig_len{$CHR} // 0) ? $end : $contig_len{$CHR};
		}
	}
	close $IN_SNPidentity;
	if($SNPcolor_list ne '')
	{
		my @arr_color = split(",", $SNPcolor_list);#--color_list '#1f77b4,#ff7f0e,#ff7f0e,#d62728'
		my $i = 0;
		my @color_arr;
		push(@color_arr, @arr_color);
		push(@color_arr, @default_color);
		foreach my $sample (@arr_sample){$sample_color{$sample} = $color_arr[$i%$n_colors];$i++;}
	}
	else
	{
		foreach my $sample(sort keys %sample_color0)
		{
			my $color = $sample_color0{$sample};
			$sample_color{$sample} = $color;
		}
	}

	foreach my $CHR (sort keys %contig_len)
	{
		my $len = $contig_len{$CHR};
		my $len_out = commify($len);
		print "Contig: ID=$CHR, length=$len_out\n";
	}
	foreach my $sample (@arr_sample)
	{
		my $color = $sample_color{$sample};
		print "Color: Sample=$sample, color=\"$color\"\n";
	}

	if(defined $density)
	{
		$countline = 0;
		my @arr_sample1;
		open(my $IN_SNPdensity,  "<", $density)  or die "Cannot open $density: $!";
		while (<$IN_SNPdensity>) {
			chomp;
			next if /^\s*$/;  # 可选：跳过空行
			my @cols = split(/\t/, $_);
			$countline++;
			if($countline == 1)
			{
				shift(@cols);shift(@cols);shift(@cols);
				push(@arr_sample1, @cols);
				next;
			}
			else
			{
				my $CHR = shift(@cols);
				my $start = shift(@cols);
				my $end = shift(@cols);
				my $i = 0;
				my $bin_SIZE = $end - $start + 1;
				$hash_bin2{$bin_SIZE} += 1;
				foreach my $valueX (@cols)
				{
					my $Sample = $arr_sample1[$i];
					$SNP_density{$CHR}->{$start}->{$end}->{$Sample} = $valueX;
					$i++;
				}
			}
		}
		close $IN_SNPdensity;
	}
	my $max_key1 = (sort { $hash_bin1{$b} <=> $hash_bin1{$a} } keys %hash_bin1)[0];
	my $max_key2 = (sort { $hash_bin2{$b} <=> $hash_bin2{$a} } keys %hash_bin2)[0];
	if($max_key1 ne $max_key2)
	{
		#$max_key1 = num2char($max_key1);
		#$max_key2 = num2char($max_key2);
		die "Error: bin size between identity ($identity) and density ($density) is inconsistent! ".
			"\nSource bin range: $max_key1, Density bin range: $max_key2\n";
	}
	elsif($max_key1 eq $max_key2){$bin_size = $max_key1;}
	$bin_char = num2char($bin_size);
	if(!defined $output){$output = "$outdir" . "$prefix" . 'GenomeSyn.' . "$bin_char" . '.pdf';}
	# 调整画布大小
	my $chrname_max_num = 0;
	my $global_max = 0;
	my $global_min = undef;
	my $chr_num = 0;
	foreach my $CHR (sort keys %contig_len)
	{
		 $chr_num++;
		 my $Chrnamelen = length($CHR);
		 my $chr_len = $contig_len{$CHR};
		 # 更新最大值
		 $global_max = $chr_len if $chr_len > $global_max;
		 # 更新最小值
		 if (!defined($global_min) || $chr_len < $global_min) {
			$global_min = $chr_len;
		 }
		 $chrname_max_num = $Chrnamelen if $Chrnamelen > $chrname_max_num;
	}
	$chrname_max_len = estimate_svg_text_width($chrname_max_num);
	$SVG_x = $SVG_x_left + $chrname_max_len + 2;
	$scale = $global_max/$SVG_main;
	my $SVG1= SVG -> new();
	my $SVG1_canvas_w = sprintf("%.0f", $SVG_main + $SVG_x + $SVG_x_right + 15);
	my $SVG1_canvas_h = sprintf("%.0f", ($ChrHight + $Chrtop + $Chrdottom)* ($chr_num + 1) + $SVG_x_top + $SVG_x_bottom);
	$SVG1= SVG -> new(width => $SVG1_canvas_w . 'mm', height   => $SVG1_canvas_h . 'mm', viewBox => "0 0 $SVG1_canvas_w $SVG1_canvas_h");

	#绘制染色体块及刻度线
	draw_vcf_chr_block($SVG1, \%contig_len, \%sample_color, \%SNP_density, \%SNP_identity, \%sample_index);
	#my ($SVG1, $contig_len_ref, $sample_color_ref, $SNP_density_ref, $SNP_identity_ref, $sample_index_ref) = @_;
	my $svg_file = $output;
	my $svg_pdf = 1;
	if($svg_file =~ /\.pdf$/i){ $svg_file =~ s/\.pdf$/.svg/i; $svg_pdf = 2;}
	if($svg_file =~ /\.png$/i){ $svg_file =~ s/\.png$/.svg/i; $svg_pdf = 3;}
	elsif($svg_file =~ /\.svg$/i){}
	else{$svg_file .= '.svg'; $svg_pdf = 2;}
	# 输出绘图文件
	open my $svg_fh, '>', $svg_file or die "无法写入 $svg_file: $!";
	print $svg_fh $SVG1->xmlify(), "\n";
	close $svg_fh;
	print"\nCanvas width: $SVG1_canvas_w mm\n";
	print"Canvas height: $SVG1_canvas_h mm\n";
	my $pdf_file = '';
	if(($svg_pdf == 2)or($svg_pdf == 3))
	{
		# 先生成目标文件名
		my $tmp_pdf = $svg_file;
		if($svg_pdf == 2){$tmp_pdf =~ s/\.svg$/.pdf/i;}
		elsif($svg_pdf == 3){$tmp_pdf =~ s/\.svg$/.png/i;}
		# 调用 CairoSVG 转换
		if (system("cairosvg $svg_file -o $tmp_pdf") == 0) {
			# 转换成功时，才更新 $pdf_file
			$pdf_file = $tmp_pdf;
		}
		else {
			#warn "转换失败：$!";
			warn "Conversion failed: $!";
		}
	}
	
	print "\ndrawing_SVG1:--OK!--\n";
	print"-- $svg_file\n";
	if($pdf_file ne ''){print"-- $pdf_file\n";}
}


# 用于打印帮助信息的函数
sub print_usage {
    print <<'END_HELP';
usage: GenomeSyn2 [options]
example:  
 *************************************************************************************
 * Quick start:  GenomeSyn2 --align mummer --genome ./fa_data/ --outdir ./output/ --thread 30
 *               GenomeSyn2 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30
 *************************************************************************************
  1) Show this help message:
     GenomeSyn2 --help
  2) Show the full manual page with detailed documentation:
     GenomeSyn2 --man
  3) One-step run command:
     GenomeSyn2 --align mummer/minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30
	 GenomeSyn2 --align blastp/mmseqs/diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30
  4) Calculate SNP density and SNP identity from a VCF file to visualize multi-parental origin contributions:
     GenomeSyn2 --vcf ./parents.progeny.snps.genotype.vcf --bin 50000
  5) Based on SNP density and SNP identity statistics, plot the multi-parental origins contribution:
     GenomeSyn2 --identity ./SNP_identity.50Kb.bed --density ./SNP_density.50Kb.bed
  6) Generate a file information table based on the given path and file type, for use in downstream alignment or analysis:
     GenomeSyn2 --type anno --path ./your_path/ --out anno.info.tsv
  7) Display and modify the Configuration:
     GenomeSyn2 --conf ? > total.conf
	 GenomeSyn2 --anno ? >> total.conf
  8) Run GenomeSyn2 using the Configuration file for full pipeline execution:
     GenomeSyn2 --conf total.conf

  -h, --help       Show this help message
  -m, --man        Show the full manual page with detailed documentation
  -v, --version    Show program's version number and exit

  --align          Specifies the alignment software to be used: <mummer/minimap2/blastp/mmseqs/diamond>
  --genome   <dir> Path to the directory containing one or more genome FASTA files
                   Filenames should be preprocessed to start with an Arabic numeral followed by a dot (e.g., 1.G1.fa, 2.G2.fa). 
                   The program will sort the files numerically for downstream alignment and visualization.
  --gene     <dir> Path to the directory containing gene annotation files corresponding to the genomes
                   Filenames should be preprocessed to start with an Arabic numeral followed by a dot (e.g., 1.G1.gff3, 2.G2.gff3). 
                   The program will sort the files numerically for downstream alignment and visualization.
  --outdir   <dir> Specify the output directory for alignment result files
  --thread   <int> Number of threads to use for parallel processing (default: 1)

  --vcf      <vcf> Input VCF file containing SNP genotypes
  --bin      <int> Bin size (genomic window) to calculate SNP density and SNP identity
  --identity <bed> BED file containing precomputed SNP identity information across bins
  --density  <bed> BED file containing precomputed SNP density information across bins

  --type           Type of input data: <fa|prot|anno>
                   fa    - genome sequences or chromosome length (FASTA/bed)
                   prot  - protein sequences (FASTA)
                   anno  - genome annotation files (GFF/GTF/bed)
  --path     <dir> Generate a file named 'X.tsv' in the current directory(--out X.tsv), containing absolute 
                   paths of all files in the given path
  --out            Set the output file name to be generated

  --anno           Configuration file for displaying and editing annotation information
  --conf           Display and modify the Configuration file
END_HELP
}
#die "Please provide a config file using --conf\n" unless $conf_info;



# 退出程序
exit;

#####################################################
# 子程序设定
#####################################################

# 检查文件是否存在且可读
sub check_file_exists {
    my ($file) = @_;
    unless (-e $file && -r $file) {
        die "Error: Config file '$file' does not exist or is not readable.\n";
    }
}

# 读取配置文件
sub read_config_file {
    my ($config_file) = @_;
    my %config;
    my $current_section = '';
    check_file_exists($config_file);
	open my $fh, '<', $config_file;
    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/^\s+|\s+$//g;  # 去除首尾空格
        next if $line eq '' or $line =~ /^#/;  # 跳过空行和注释行
        
        # 区块名，如 [genome_info],[synteny_info],[save_info] 或 [anno_info],[optional_parameter],[color_setup],[centromere_info],[telomere_info]
		if ($line =~ /^\[([^\]]+)\]/) {
			my $section_name = $1;
			$section_name =~ s/\s*#.*$//;  # 去除井号后注释
			$section_name =~ s/\s+//g;     # 去除所有空格
			$current_section = $section_name;
			# 小写匹配跳过标志
			my %skip_flags = (
				'anno_info:no'        => \$skip_anno_info,
				'optional_parameter:no' => \$skip_opt_par,
				'color_setup:no'      => \$skip_color_setup,
				'centromere_info:no'  => \$skip_centromere_info,
				'telomere_info:no'    => \$skip_telomere_info,
				'show_region:no'    => \$skip_region_info,
			);
			my $lower_section = lc($current_section);
			if (exists $skip_flags{$lower_section}) {
				${ $skip_flags{$lower_section} } = 1;
			}
			next;
		}
		# 处理 key = value
		if ($line =~ /^([^=]+?)\s*=\s*(.+)$/) {
			my ($key0, $value) = ($1, $2);
			$key0   =~ s/^\s+|\s+$//g;
			$value =~ s/\s+#.*$//;
			$value =~ s/^\s+|\s+$//g;
			my $lower_section = lc($current_section);
			my $key = lc($key0);
			my $base_section = (split /:/, $lower_section)[0];
			# 定义所有可能带数组格式的 section（并且可能被 skip）
			my %section_skip_map = (
				'anno_info'         => \$skip_anno_info,
				'optional_parameter'=> \$skip_opt_par,
				'color_setup'       => \$skip_color_setup,
				'centromere_info'   => \$skip_centromere_info,
				'telomere_info'     => \$skip_telomere_info,
				'show_region'    => \$skip_region_info,
			);
			if (exists $section_skip_map{$base_section} && !${ $section_skip_map{$base_section} }) {
				# section 允许处理
				if ($value =~ /^\[(.+)\]$/) {
					#my @items = split /\s*,\s*/, $1;
					#$config{$base_section}{$key} = \@items;
					$config{$base_section}{$key} = $1;
				} else {
					$config{$base_section}{$key} = $value;
				}
			}
			# 不属于跳过 section，或者未在处理名单中
			elsif (!exists $section_skip_map{$base_section}) {
				$config{$base_section}{$key} = $value;
			}
		}
    }
    close $fh;
    return %config;
}

sub process_required_params {
    # my ($config_ref) = @_;
    my ($config_ref) = @_;
	
    # 检查必需的参数是否存在
    my @required_sections = ('genome_info', 'synteny_info', 'save_info');
    foreach my $section (@required_sections) {
        unless (exists $config_ref->{$section}) {
            die "Error: Required section [$section] is missing in the configuration file.\n";
        }
    }
    
    # 处理 genome_info 部分
    my $genome_info = $config_ref->{'genome_info'};
    unless (exists $genome_info->{'gonomes_list'}) {
        die "Error: Required parameter 'gonomes_list' is missing in [genome_info] section.\n";
    }
    
    # 处理 synteny_info 部分
    my $synteny_info = $config_ref->{'synteny_info'};
    unless (exists $synteny_info->{'synteny_list'}) {
        die "Error: Required parameter 'Synteny_list' is missing in [synteny_info] section.\n";
    }
    
    # 处理 save_info 部分
    my $save_info = $config_ref->{'save_info'};
    unless (exists $save_info->{'savefig1'} || exists $save_info->{'savefig2'}) {
        die "Error: At least one of 'savefig1' or 'savefig2' is required in [save_info] section.\n";
    }
    print "\n=== Configuration Summary ===\n";
    # 读取基因组信息文件
    my $genomes_file = $genome_info->{'gonomes_list'};
    if (-e $genomes_file) {
        print "Reading genome information from $genomes_file...\n";
        # 这里可以添加读取基因组信息文件的代码
		my $genome_type0 = $genome_info->{'gonomes_filetype'};
		my $genome_type = lc($genome_type0);
		my @Gfile_suffix;
		if(($genome_type eq 'fasta')||($genome_type eq 'fa')||($genome_type eq 'fna'))
		{
			 open FL,"$genomes_file";
			 while(<FL>)
			{
				 chomp;
				 next if /^#/;  # 跳过以 # 开头的注释行
				 next if /^\s*$/;  # 可选：跳过空行
				 my @tem = split /\t/;
				 $hash_Ginfo{$tem[0]}->{'fasta'} = $tem[1];
				 $hash_Ginfo{$tem[0]}->{'name'} = $tem[2];
				 $hash_Ginfo{$tem[0]}->{'tags'} = $tem[3];
				 if ($tem[1] =~ /\.([^.\/\\]+)$/)
				 {
					 my $ext = $1;
					 push(@Gfile_suffix,$ext);
					unless ($ext eq 'fasta' || $ext eq 'fa' || $ext eq 'fna') {
						print "\nWarning: gonomes_filetype = $genome_type0\n";
						die "Error: File '$tem[1]' does not have a valid genome file extension. Please check if it is a genome sequence file with suffix .fasta, .fa, or .fna\n";
					}
				 }
				 else {
					die "Error: Cannot detect file extension from '$tem[1]'. Ensure the genome file has a proper extension like .fasta, .fa, or .fna\n";
				 }
			}
			close FL;
			foreach my $Gnum(sort{$a<=>$b} keys %hash_Ginfo)
			{
				 my $Gfasta = $hash_Ginfo{$Gnum}->{'fasta'};
				 my $chrin = Bio::SeqIO->new(-file=>"$Gfasta");
				 while(my $seq = $chrin->next_seq())
				{
					 my $Chrname=$seq->id();
					 my $Chrlength=$seq->length();
					 $hash_Ginfo{$Gnum}->{'chr'}->{$Chrname} = $Chrlength;
				}
			}
		}
		elsif(($genome_type eq 'bed')||($genome_type eq 'tsv')||($genome_type eq 'txt'))
		{
			open FL,"$genomes_file";
			while(<FL>)
			{
				 chomp;
				 next if /^#/;  # 跳过以 # 开头的注释行
				 next if /^\s*$/;  # 可选：跳过空行
				 my @tem = split /\t/;
				 $hash_Ginfo{$tem[0]}->{'fasta'} = $tem[1];
				 $hash_Ginfo{$tem[0]}->{'name'} = $tem[2];
				 $hash_Ginfo{$tem[0]}->{'tags'} = $tem[3];
				 if ($tem[1] =~ /\.([^.\/\\]+)$/)
				 {
					 my $ext = $1;
					 push(@Gfile_suffix,$ext);
					unless ($ext eq 'bed' || $ext eq 'tsv' || $ext eq 'txt') {
						print "\nWarning: gonomes_filetype = $genome_type0\n";
						die "Error: File '$tem[1]' does not have a valid genome file extension. Please check if it is a genome sequence file with suffix .bed, .tsv, or .txt\n";
					}
				 }
				 else {
					die "Error: Cannot detect file extension from '$tem[1]'. Ensure the genome file has a proper extension like .bed, .tsv, or .txt\n";
				 }
			}
			close FL;
			foreach my $Gnum(sort{$a<=>$b} keys %hash_Ginfo)
			{
				 my $Gbed = $hash_Ginfo{$Gnum}->{'fasta'};
				 my $chr_numX = 0;
				 open(my $FLbed, "<", $Gbed) or die "Cannot open $Gbed: $!\n";
				 while(<$FLbed>)
				 {
					 chomp;
					 next if /^#/;  # 跳过以 # 开头的注释行
					 next if /^\s*$/;  # 可选：跳过空行
					 my @tem = split /\t/;
					 my ($Chrname, $Chrlength, $ChrnameGAI);
					 $chr_numX++;
					# 判断列数
					if (@tem == 2) {
						($Chrname, $Chrlength) = @tem;
						$hash_Ginfo{$Gnum}->{'chr'}->{$Chrname} = $Chrlength;
						$hash_chrGAI{$Gnum}->{$Chrname} = $Chrname;
					}
					elsif(@tem == 3) {
						($Chrname, $Chrlength, $ChrnameGAI) = @tem;
						$hash_Ginfo{$Gnum}->{'chr'}->{$Chrname} = $Chrlength;
						#$hash_Ginfo{$Gnum}->{'chrGAI'}->{$ChrnameGAI} = $Chrlength;
						$hash_chrGAI{$Gnum}->{$Chrname} = $ChrnameGAI;
					}
					else
					{
						$Chrname = $tem[0];
						$Chrlength = $tem[1];
						$hash_Ginfo{$Gnum}->{'chr'}->{$Chrname} = $Chrlength;
						$hash_chrGAI{$Gnum}->{$Chrname} = $Chrname;
					}
					$hash_read_chr_order{$Gnum}->{$Chrname} = $chr_numX;
					if($Gnum == 1){push(@arr_ref_chrname, $Chrname);}
				 }
				 close $FLbed;
			}
		}
    } else {
        die "Error: Genome information file '$genomes_file' does not exist.\n";
    }
    # 读取共线性信息文件
    my $synteny_file = $synteny_info->{'synteny_list'};
    if (-e $synteny_file) {
        print "Reading synteny information from $synteny_file...\n";
        # 这里可以添加读取共线性信息文件的代码
		 open SYN_FL,"$synteny_file";
		 while(<SYN_FL>)
		{
			 chomp;
			 next if /^#/;  # 跳过以 # 开头的注释行
			 next if /^\s*$/;  # 可选：跳过空行
			 my @tem = split /\t/;
			 $hash_syninfo{$tem[0]}->{'reference'} = $tem[1];
			 $hash_syninfo{$tem[0]}->{'query'} = $tem[2];
			 $hash_syninfo{$tem[0]}->{'align'} = $tem[3];
			 #print"$hash_syninfo{$tem[0]}->{'align'}\n";
		}
		close SYN_FL;
    } else {
        die "Error: Synteny information file '$synteny_file' does not exist.\n";
    }
}

sub restructure_anno_info {
    my ($anno_ref) = @_;
    
    # 将每个字段字符串转为数组
    my %arrays;
    foreach my $key (keys %$anno_ref) {
        my $val = $anno_ref->{$key};
		$val =~ s/['"]//g;
        my @items = split /\s*,\s*/, $val;
        $arrays{$key} = \@items;
    }

    # 构建每个注释项
    my %anno_struct;
    my $num_items = scalar @{ $arrays{anno_name} };
    for (my $i = 0; $i < $num_items; $i++) {
        my %entry;
        foreach my $key (keys %arrays) {
            $entry{$key} = $arrays{$key}->[$i];
        }
        $anno_struct{ $i + 1 } = \%entry;
    }

    return \%anno_struct;
}

# 打印配置信息摘要
sub print_config_summary {
    my ($config_ref) = @_;
    #print "\n=== Configuration Summary ===\n";
    # 打印基本配置信息
    #print "Genome Information File: " . $config_ref->{'genome_info'}->{'gonomes_list'} . "\n";
    #print "Synteny Information File: " . $config_ref->{'synteny_info'}->{'synteny_list'} . "\n";
    # 打印注释信息
    if (exists $config_ref->{'anno_info'}) {
		my $anno_info_raw = $config_ref->{'anno_info'};
		my $anno_struct_ref = restructure_anno_info($anno_info_raw);
		
		my %anno_info = %$anno_struct_ref;
        my @anno_numbers = sort { $a <=> $b } keys %anno_info;
        
        print "\nAnnotation Information:\n";
        foreach my $anno_number (@anno_numbers) {
            my $anno_entry = $anno_info{$anno_number};
			my $anno_position0 = $anno_entry->{'anno_position'};
			my $anno_height0 = $anno_entry->{'anno_height'};
            print "  $anno_number. " . $anno_entry->{'anno_name'} . " (Type: " . $anno_entry->{'anno_type'} . "): " . "$anno_entry->{'anno_list'}" . "\n";
			# 更新注释区域的最大高度
			if($anno_position0 eq 'top'){$Chrtop = $anno_height0 if $anno_height0 > $Chrtop;}
			elsif($anno_position0 eq 'bottom'){$Chrdottom = $anno_height0 if $anno_height0 > $Chrdottom;}
        }
		#print"\n\$Chrtop: $Chrtop\n";
		#print"\$Chrdottom: $Chrdottom\n";
    }
	find_best_synteny_matches(\%hash_Ginfo,\%hash_syninfo);
	#基因绘制
	if(exists $config_ref->{'show_region'})
	{
		my $outfigure1 = '';
		$outfigure1 = drawing_region($config_ref, \%hash_syninfo, \%hash_Ginfo);
		#print "zwzhou\n";
		print "  - $outfigure1\n" if $outfigure1 ne '';
		#print "  - " . $config_ref->{'save_info'}->{'savefig1'} . "\n" if exists $config_ref->{'save_info'}->{'savefig1'};
		print "=============================\n\n";
	}
	else {  # 绘图命令
		 my $global_max = 0;
		 my $global_min = undef;
		 my $Gname_max_num = 0;
		 my $chrname_max_num = 0;
		 my $chr_num_min = undef;
		 my $genome_num = 0;
		 if (exists $config_ref->{'synteny_info'}->{'line_type'}) {$syntent_type = $config_ref->{'synteny_info'}->{'line_type'};}
		foreach my $Gnum (sort{$a<=>$b} keys %hash_Ginfo)
		{
			my $Gname = $hash_Ginfo{$Gnum}->{'name'};
			my $hashG = $hash_Ginfo{$Gnum}->{'chr'};
			my $chr_num = 0;
			$genome_num++;
			##### print"$Gnum:$Gname\n";
			foreach my $chr_name (sort keys %{$hashG})
			{
				 $chr_num++;
				 my $chr_len = $hash_Ginfo{$Gnum}->{'chr'}->{$chr_name};
				 ##### print "$chr_name\t$chr_len\n";
				 # 更新最大值
				 $global_max = $chr_len if $chr_len > $global_max;
				 # 更新最小值
				 if (!defined($global_min) || $chr_len < $global_min) {
					$global_min = $chr_len;
				}
				# 更新基因组名称最大字符串的字符数目
				my $Glen = length($Gname);
				$Gname_max_num = $Glen if $Glen > $Gname_max_num;
				# 更新染色体名称最大字符串的字符数目
				my $Chrlen = length($hash_chrGAI{$Gnum}->{$chr_name});
				$chrname_max_num = $Chrlen if $Chrlen > $chrname_max_num;
				
			}
			 if (!defined($chr_num_min) || $chr_num < $chr_num_min) {
				$chr_num_min = $chr_num;
			}
		}
		$Gname_max_len = estimate_svg_text_width($Gname_max_num);
		$chrname_max_len = estimate_svg_text_width($chrname_max_num);
		#print"\$Gname_max_num:$Gname_max_num\n\$Gname_max_len:$Gname_max_len\n";
		#print"\$chrname_max_num:$chrname_max_num\n\$chrname_max_len:$chrname_max_len\n";
		my $outfigure1 = '';
		my $outfigure2 = '';
		if(exists $config_ref->{'save_info'}->{'savefig1'})
		{
			$outfigure1 = drawing_SVG1($config_ref,$global_max,$global_min,$Gname_max_num,$chrname_max_num,$chr_num_min,$genome_num);
		}
		if(exists $config_ref->{'save_info'}->{'savefig2'})
		{
			$outfigure2 = drawing_SVG2($config_ref,$global_max,$global_min,$Gname_max_num,$chrname_max_num,$chr_num_min,$genome_num);
		}
		# 打印保存信息
		print "\nOutput Files:\n";
		print "  - $outfigure1\n" if $outfigure1 ne '';
		print "  - $outfigure2\n" if $outfigure2 ne '';
		#print "  - " . $config_ref->{'save_info'}->{'savefig1'} . "\n" if exists $config_ref->{'save_info'}->{'savefig1'};
		#print "  - " . $config_ref->{'save_info'}->{'savefig2'} . "\n" if exists $config_ref->{'save_info'}->{'savefig2'};
		print "=============================\n\n";
	}
}


sub commify {
    my $num = shift;
    $num = reverse $num;
    $num =~ s/(\d{3})(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $num;
}

sub drawing_region {
	 my ($config_ref,$hash_syninfo_ref, $hash_Ginfo_ref) = @_;
     my $global_max = 0;
     my $global_min = undef;
	 my $Gname_max_num = 0;
	 my $chrname_max_num = 0;
	 my $chr_num_min = undef;
	 my $genome_num = 0;
	 if (exists $config_ref->{'synteny_info'}->{'line_type'}) {$syntent_type = $config_ref->{'synteny_info'}->{'line_type'};}
	 my $gene_id = 'NA';
	 my $show_region = 'NA';
	 my $gap_threshold = 1_000_000; #1Mb
	 my $gene_list = 'NA';
	 my ($GnumX, $GnameX, $ChrX, $StartX, $EndX);
	 my $StartX0;
	 my $EndX0;
	 my %hash_region;
	 my ($GnumX_trans, $GnameX_trans, $ChrX_trans, $StartX_trans, $EndX_trans);
	if (exists $config_ref->{'show_region'}) {
		$gene_id = defined $config_ref->{'show_region'}->{'gene_id'} ? $config_ref->{'show_region'}->{'gene_id'} : 'NA';
		$show_region = defined $config_ref->{'show_region'}->{'region'} ? $config_ref->{'show_region'}->{'region'} : 'NA';
		$gap_threshold = defined $config_ref->{'show_region'}->{'gap_length'} ? $config_ref->{'show_region'}->{'gap_length'} : 1_000_000;
		$gene_list = defined $config_ref->{'show_region'}->{'gene_list'} ? $config_ref->{'show_region'}->{'gene_list'} : 'NA';
		my @arrX = split(':',$show_region);
		$GnameX = $arrX[0];
		$ChrX = $arrX[1];
		my $startend = $arrX[2];
		$startend =~ s/[,\s]//g;           # 去掉所有空格
		($StartX, $EndX) = split(/-/, $startend);
		$StartX0 = $StartX;
		$EndX0 = $EndX;
		#反向查找部分
		$GnameX_trans = $GnameX;
		$ChrX_trans = $ChrX;
		$StartX_trans = $StartX;
		$EndX_trans = $EndX;
	}
	foreach my $Gnum (sort{$a<=>$b} keys %hash_Ginfo)
	{
		 my $Gname = $hash_Ginfo{$Gnum}->{'name'};
		 if($GnameX eq $Gname){$GnumX = $Gnum;$GnumX_trans = $Gnum;}
	}
	my %hash_SYN;
	my %result_SYN;
	my %hash_SYN_R;
	my %hash_chr_region;
	#$hash_region{$GnumX} = "$GnameX" . '_:_' . "$ChrX" . '_:_' . "$StartX" . '_:_' . "$EndX";
	#print"20250911:test\n\$GnumX:$GnumX\n";
	if($GnumX == 1)
	{
		# 读取共线性信息文件
		my $chr_minR = 1e12;   # 初始化一个很大的数
		my $chr_maxR = -1;     # 初始化一个很小的数
		my $chrRsave;
		my $chrQsave;
		foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
		{
			#print"test:$Syn_num\n";
			$genome_num++;
			my $ref_genome   = $genome_num;
			my $query_genome = $genome_num + 1;
			my $lenR_max_start;
			my $lenR_max_end;
			my $GnameR = $hash_Ginfo_ref->{$ref_genome}->{'name'};
			my $GnameQ = $hash_Ginfo_ref->{$query_genome}->{'name'};
			my @arr_chrR = @{$aligned_order{$ref_genome}};
			my @arr_chrQ = @{$aligned_order{$query_genome}};
			# 建立 chr => index 的映射，方便快速查找下标
			my %posR = map { $arr_chrR[$_] => $_ } 0 .. $#arr_chrR;
			my %posQ = map { $arr_chrQ[$_] => $_ } 0 .. $#arr_chrQ;
			my $Syn_align = $hash_syninfo_ref->{$Syn_num}->{'align'};
			my $j = 0;
			my $chr_min = 1e12;   # 初始化一个很大的数
			my $chr_max = -1;     # 初始化一个很小的数
			open my $FL_align, "<", $Syn_align or die "Cannot open $Syn_align: $!";
			while(<$FL_align>)
			{
				chomp;
				next if /^#/;  # 跳过以 # 开头的注释行
				next if /^\s*$/;  # 跳过空行
				my @tem = split /\t/;
				my $chrR = $tem[0];
				my $chrQ = $tem[3];
				if($chrR eq $ChrX)
				{
					my ($startR, $endR, $startQ, $endQ);
					# 先检查 chr 是否存在于各自数组中
					next unless exists $posR{$chrR};
					next unless exists $posQ{$chrQ};
					# 索引位置必须相同
					if ($posR{$chrR} == $posQ{$chrQ}) {
						$j++;
						if($j == 1){$chrQsave = $chrQ;}
						my $strandR = $chr_orient{$ref_genome}->{$chrR};
						my $strandQ = $chr_orient{$query_genome}->{$chrQ};
						$startR = $tem[1];
						$endR   = $tem[2];
						$startQ = $tem[4];
						$endQ   = $tem[5];
						my $strand = $tem[6];
						#my ($GnumX, $GnameX, $ChrX, $StartX, $EndX);
						#if ($StartX <= $endR and $startR <= $EndX)
						# case1: $startR 在 [$StartX, $EndX] 里面
						# case2: $endR   在 [$StartX, $EndX] 里面
						# case3: [$StartX, $EndX] 完全落在 [$startR, $endR] 里面
						if((($StartX <= $startR)and($startR <= $EndX)) or (($StartX <= $endR)and($endR <= $EndX)) or (($startR <= $StartX)and($EndX <= $endR)))
						{
							# 更新 chr_min 和 chr_max
							my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
							my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
							my $minR = ($startR < $endR) ? $startR : $endR;
							my $maxR = ($startR > $endR) ? $startR : $endR;
							my $chr_min0 = $chr_min;
							my $chr_max0 = $chr_max;
							my $chr_minR0 = $chr_minR;
							my $chr_maxR0 = $chr_maxR;
							#my ($chr_minR0, $chr_maxR0);
							$chr_min0 = $minQ if $minQ < $chr_min0;
							$chr_max0 = $maxQ if $maxQ > $chr_max0;
							$chr_minR0 = $minR if $minR < $chr_minR0;
							$chr_maxR0 = $maxR if $maxR > $chr_maxR0;
							#my $input_len = abs($EndX0 - $StartX0) + 1;             # 输入长度 1 Mb
							my $ref_len0 = abs($chr_maxR0 - $chr_minR0) + 1;
							my $query_len0 = abs($chr_max0 - $chr_min0) + 1;
							my $ref_len = abs($chr_maxR - $chr_minR) + 1;
							my $query_len = abs($chr_max - $chr_min) + 1;
							# 如果比对区间太大（比如超过输入的 2 倍），就跳过
							#next if $query_len0 > 2 * $ref_len0;
							$chr_min = $minQ if $minQ < $chr_min;
							$chr_max = $maxQ if $maxQ > $chr_max;
							$chr_minR = $minR if $minR < $chr_minR;
							$chr_maxR = $maxR if $maxR > $chr_maxR;
							my $keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
							my $keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
							$hash_SYN{$Syn_num}->{$keyR}->{$keyQ} = $strand;
							$hash_SYN_R{$Syn_num}->{$ref_genome}->{$chrR}->{$startR}->{$endR}=0;
							#print"TEST1:$Syn_num\t$keyR\t$keyQ\t$strand\n";
							#print"test222:$Syn_num\n";
						}
					}
				}
			}
			close $FL_align;

			$j = 0;
			my $region_Rmin = 1e12;
			my $region_Rmax = -1;
			my $region_Qmin = 1e12;
			my $region_Qmax = -1;
			my $hash_G1 = $hash_SYN_R{$Syn_num};
			foreach my $ref_genome_key (sort{$a<=>$b} keys %{$hash_G1})
			{
				my $hash_G2 = $hash_SYN_R{$Syn_num}->{$ref_genome_key};
				my $ref_len = 0;
				my $query_len = 0;
				foreach my $chrR (sort keys %{$hash_G2})
				{
					my $hash_G3 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR};
					foreach my $startR (sort{$a<=>$b} keys %{$hash_G3})
					{
						my $hash_G4 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR}->{$startR};
						foreach my $endR (sort{$a<=>$b} keys %{$hash_G4})
						{
							my $keyR = "$ref_genome_key" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
							my $hash_G5 = $hash_SYN{$Syn_num}->{$keyR};
							foreach my $keyQ(sort keys %{$hash_G5})
							{
								my $strand = $hash_SYN{$Syn_num}->{$keyR}->{$keyQ};
								my ($query_genome_key, $chrQ, $startQ, $endQ) = split(/:/,$keyQ);
								#print"TEST2:$Syn_num\t$keyR\t$keyQ\t$strand\n";
								if($strand eq '+')
								{
									if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
									{
										# 完全在范围内，不变
									}
									elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
									{
										#裁掉reference左侧，query左侧
										my $startQ0 = $endQ - abs($endR - $StartX);
										$startR = $StartX;
										$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
									}
									elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
									{
										# 裁掉reference右侧，query右侧
										my $endQ0 = $startQ + abs($EndX - $startR);
										$endR = $EndX;
										$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
									}
									elsif(($startR <= $StartX)and($EndX <= $endR))
									{
										# 区间完全覆盖，取中间子段
										my $left_len = abs($StartX - $startR);
										my $right_len = abs($endR - $EndX);
										$startR = $StartX;
										$endR = $EndX;
										$startQ = $startQ + $left_len;
										$endQ = $endQ - $right_len;
									}
								}
								elsif($strand eq '-')
								{
									if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
									{
										# 完全在范围内，不变
									}
									elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
									{
										#裁掉reference左侧，query右侧
										my $endQ0 = $startQ + abs($endR - $StartX);
										$startR = $StartX;
										$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
									}
									elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
									{
										# 裁掉reference右侧，query左侧
										my $startQ0 = $endQ - abs($EndX - $startR);
										$endR = $EndX;
										$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
									}
									elsif(($startR <= $StartX)and($EndX <= $endR))
									{
										# 区间完全覆盖，取中间子段
										my $left_len = abs($StartX - $startR);
										my $right_len = abs($endR - $EndX);
										$startR = $StartX;
										$endR = $EndX;
										$startQ = $startQ + $right_len;
										$endQ = $endQ - $left_len;
									}
								}
								my $ref_len0 = $ref_len;
								my $query_len0 = $query_len;
								my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
								my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
								my $minR = ($startR < $endR) ? $startR : $endR;
								my $maxR = ($startR > $endR) ? $startR : $endR;
								$j++;
								if($j == 1)
								{
									# 初始化区域
									$region_Rmin = $minR;
									$region_Rmax = $maxR;
									$region_Qmin = $minQ;
									$region_Qmax = $maxQ;
									$chrRsave = $chrR;
									$chrQsave = $chrQ;
								}
								# —— 用“Query 的当前区域”做扩展窗口，筛掉距离过远的 Query 片段 ——
								my $Qgap_max = $region_Qmax + $gap_threshold;
								my $Qgap_min = $region_Qmin - $gap_threshold;
								# 若该 Query 片段完全落在扩展窗口之外，则跳过
								if ($maxQ < $Qgap_min || $minQ > $Qgap_max) {
									next;      # 丢掉与窗口不相交的片段
								}
								# —— 保留：并更新 R/Q 聚合区间 —— 
								$region_Rmin = $minR if $minR < $region_Rmin;
								$region_Rmax = $maxR if $maxR > $region_Rmax;
								$region_Qmin = $minQ if $minQ < $region_Qmin;
								$region_Qmax = $maxQ if $maxQ > $region_Qmax;
								my $new_keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
								my $new_keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
								$result_SYN{$Syn_num}->{$new_keyR}->{$new_keyQ} = $strand;
								my $len_regionR = abs($endR - $startR) + 1;
								my $len_regionQ = abs($endQ - $startQ) + 1;
								#print"TEST_1:$Syn_num\t$keyR\t$keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
								#print"TEST_2:$Syn_num\t$new_keyR\t$new_keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
							}
						}
					}
				}
			}
			# —— 若本轮没有任何片段被保留，跳过后续输出与链式更新 —— 
			if ($j == 0 || $region_Rmin == 1e12 || $region_Qmin == 1e12) {
				warn "Syn $Syn_num: no segments kept after gap filter on $GnameR/$GnameQ\n";
				next;
			}
			# —— 输出 —— 
			my $outX1 = commify($region_Rmin);
			my $outX2 = commify($region_Rmax);
			my $outX3 = commify($region_Qmin);
			my $outX4 = commify($region_Qmax);
			#print "$ref_genome:$GnameR: $chrRsave: [$outX1 - $outX2]\n";
			#print "$query_genome:$GnameQ: $chrQsave: [$outX3 - $outX4]\n\n";
			#if($genome_num==1)
			#$hash_region{$ref_genome_key} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
			#$hash_region{$query_genome_key} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
			#print"TEST5:$hash_region{$ref_genome}\n";
			#print"TEST5:$hash_region{$query_genome_key}\n";
			$hash_chr_region{$ref_genome}->{$Syn_num} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
			$hash_chr_region{$query_genome}->{$Syn_num} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
			# —— 链式更新（切换到下一基因组时让 ChrX/StartX/EndX 对应 Query 侧的区间）——
			$ChrX = $chrQsave;
			$StartX = $region_Qmin;
			$EndX = $region_Qmax;
		}
		foreach my $GNUM (sort{$a<=>$b} keys %hash_chr_region)
		{
			my $HASHG1 = $hash_chr_region{$GNUM};
			my @arr_region;
			foreach my $Syn_num (sort{$a<=>$b} keys %{$HASHG1})
			{
				my $key_region = $hash_chr_region{$GNUM}->{$Syn_num};
				push(@arr_region, $key_region);
			}
			my $count = scalar(@arr_region);
			if ($count == 0) {
				warn "Warning: no regions for genome $GNUM\n";
				next;
			}
			elsif($count == 1)
			{
				$hash_region{$GNUM} = $arr_region[0];
			}
			elsif($count == 2)
			{
				my ($Gname1, $chr1, $region_min1, $region_max1) = split(/_:_/, $arr_region[0]);
				my ($Gname2, $chr2, $region_min2, $region_max2) = split(/_:_/, $arr_region[1]);
				my $minX = ($region_min1 < $region_min2) ? $region_min1 : $region_min2;
				my $maxX = ($region_max1 > $region_max2) ? $region_max1 : $region_max2;
				$hash_region{$GNUM} = "$Gname1" . '_:_' . "$chr1" . '_:_' . "$minX" . '_:_' . "$maxX";
			}
		}
	}
	elsif($GnumX > 1)
	{
		# 正向查找部分
		{
			my $chr_minR = 1e12;   # 初始化一个很大的数
			my $chr_maxR = -1;     # 初始化一个很小的数
			my $chrRsave;
			my $chrQsave;
			# 读取共线性信息文件,从小到大
			foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
			{
				if($Syn_num >= $GnumX)
				{
					$genome_num++;
					my $ref_genome   = $Syn_num;
					my $query_genome = $Syn_num + 1;
					my $lenR_max_start;
					my $lenR_max_end;
					my $GnameR = $hash_Ginfo_ref->{$ref_genome}->{'name'};
					my $GnameQ = $hash_Ginfo_ref->{$query_genome}->{'name'};
					my @arr_chrR = @{$aligned_order{$ref_genome}};
					my @arr_chrQ = @{$aligned_order{$query_genome}};
					# 建立 chr => index 的映射，方便快速查找下标
					my %posR = map { $arr_chrR[$_] => $_ } 0 .. $#arr_chrR;
					my %posQ = map { $arr_chrQ[$_] => $_ } 0 .. $#arr_chrQ;
					my $Syn_align = $hash_syninfo_ref->{$Syn_num}->{'align'};
					my $j = 0;
					my $chr_min = 1e12;   # 初始化一个很大的数
					my $chr_max = -1;     # 初始化一个很小的数
					#print"\$Syn_align:$Syn_align\n";
					open my $FL_align, "<", $Syn_align or die "Cannot open $Syn_align: $!";
					while(<$FL_align>)
					{
						chomp;
						next if /^#/;  # 跳过以 # 开头的注释行
						next if /^\s*$/;  # 跳过空行
						my @tem = split /\t/;
						#print"XX:$tem[0]\t$tem[1]\t$tem[2]\t$tem[3]\t$tem[4]\t$tem[5]\t$tem[6]\t$tem[7]\t$tem[8]\n";
						my $chrR = $tem[0];
						my $chrQ = $tem[3];
						if($chrR eq $ChrX)
						{
							my ($startR, $endR, $startQ, $endQ);
							# 先检查 chr 是否存在于各自数组中
							next unless exists $posR{$chrR};
							next unless exists $posQ{$chrQ};
							# 索引位置必须相同
							if ($posR{$chrR} == $posQ{$chrQ}) {
								$j++;
								if($j == 1){$chrQsave = $chrQ;}
								my $strandR = $chr_orient{$ref_genome}->{$chrR};
								my $strandQ = $chr_orient{$query_genome}->{$chrQ};
								$startR = $tem[1];
								$endR   = $tem[2];
								$startQ = $tem[4];
								$endQ   = $tem[5];
								my $strand = $tem[6];
								
								#my ($GnumX, $GnameX, $ChrX, $StartX, $EndX);
								#if ($StartX <= $endR and $startR <= $EndX)
								# case1: $startR 在 [$StartX, $EndX] 里面
								# case2: $endR   在 [$StartX, $EndX] 里面
								# case3: [$StartX, $EndX] 完全落在 [$startR, $endR] 里面
								if((($StartX <= $startR)and($startR <= $EndX)) or (($StartX <= $endR)and($endR <= $EndX)) or (($startR <= $StartX)and($EndX <= $endR)))
								{
									# 更新 chr_min 和 chr_max
									#print"YY:$tem[0]\t$tem[1]\t$tem[2]\t$tem[3]\t$tem[4]\t$tem[5]\t$tem[6]\t$tem[7]\t$tem[8]\n";
									my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
									my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
									my $minR = ($startR < $endR) ? $startR : $endR;
									my $maxR = ($startR > $endR) ? $startR : $endR;
									my $chr_min0 = $chr_min;
									my $chr_max0 = $chr_max;
									my $chr_minR0 = $chr_minR;
									my $chr_maxR0 = $chr_maxR;
									#my ($chr_minR0, $chr_maxR0);
									$chr_min0 = $minQ if $minQ < $chr_min0;
									$chr_max0 = $maxQ if $maxQ > $chr_max0;
									$chr_minR0 = $minR if $minR < $chr_minR0;
									$chr_maxR0 = $maxR if $maxR > $chr_maxR0;
									#my $input_len = abs($EndX0 - $StartX0) + 1;             # 输入长度 1 Mb
									my $ref_len0 = abs($chr_maxR0 - $chr_minR0) + 1;
									my $query_len0 = abs($chr_max0 - $chr_min0) + 1;
									my $ref_len = abs($chr_maxR - $chr_minR) + 1;
									my $query_len = abs($chr_max - $chr_min) + 1;
									# 如果比对区间太大（比如超过输入的 2 倍），就跳过
									#next if $query_len0 > 2 * $ref_len0;
									$chr_min = $minQ if $minQ < $chr_min;
									$chr_max = $maxQ if $maxQ > $chr_max;
									$chr_minR = $minR if $minR < $chr_minR;
									$chr_maxR = $maxR if $maxR > $chr_maxR;
									my $keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
									my $keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
									$hash_SYN{$Syn_num}->{$keyR}->{$keyQ} = $strand;
									$hash_SYN_R{$Syn_num}->{$ref_genome}->{$chrR}->{$startR}->{$endR}=0;
									#print"+:$Syn_num\t$keyR\t$keyQ\t$strand\n";
									#print"+:$Syn_num\n";
								}
							}
						}
					}
					close $FL_align;
					$j = 0;
					my $region_Rmin = 1e12;
					my $region_Rmax = -1;
					my $region_Qmin = 1e12;
					my $region_Qmax = -1;
					my $hash_G1 = $hash_SYN_R{$Syn_num};
					foreach my $ref_genome_key (sort{$a<=>$b} keys %{$hash_G1})
					{
						my $hash_G2 = $hash_SYN_R{$Syn_num}->{$ref_genome_key};
						my $ref_len = 0;
						my $query_len = 0;
						foreach my $chrR (sort keys %{$hash_G2})
						{
							my $hash_G3 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR};
							foreach my $startR (sort{$a<=>$b} keys %{$hash_G3})
							{
								my $hash_G4 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR}->{$startR};
								foreach my $endR (sort{$a<=>$b} keys %{$hash_G4})
								{
									my $keyR = "$ref_genome_key" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
									my $hash_G5 = $hash_SYN{$Syn_num}->{$keyR};
									foreach my $keyQ(sort keys %{$hash_G5})
									{
										my $strand = $hash_SYN{$Syn_num}->{$keyR}->{$keyQ};
										my ($query_genome_key, $chrQ, $startQ, $endQ) = split(/:/,$keyQ);
										#print"TEST2:$Syn_num\t$keyR\t$keyQ\t$strand\n";
										if($strand eq '+')
										{
											if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
											{
												# 完全在范围内，不变
											}
											elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
											{
												#裁掉reference左侧，query左侧
												my $startQ0 = $endQ - abs($endR - $StartX);
												$startR = $StartX;
												$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
											}
											elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
											{
												# 裁掉reference右侧，query右侧
												my $endQ0 = $startQ + abs($EndX - $startR);
												$endR = $EndX;
												$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
											}
											elsif(($startR <= $StartX)and($EndX <= $endR))
											{
												# 区间完全覆盖，取中间子段
												my $left_len = abs($StartX - $startR);
												my $right_len = abs($endR - $EndX);
												$startR = $StartX;
												$endR = $EndX;
												$startQ = $startQ + $left_len;
												$endQ = $endQ - $right_len;
											}
										}
										elsif($strand eq '-')
										{
											if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
											{
												# 完全在范围内，不变
											}
											elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
											{
												#裁掉reference左侧，query右侧
												my $endQ0 = $startQ + abs($endR - $StartX);
												$startR = $StartX;
												$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
											}
											elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
											{
												# 裁掉reference右侧，query左侧
												my $startQ0 = $endQ - abs($EndX - $startR);
												$endR = $EndX;
												$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
											}
											elsif(($startR <= $StartX)and($EndX <= $endR))
											{
												# 区间完全覆盖，取中间子段
												my $left_len = abs($StartX - $startR);
												my $right_len = abs($endR - $EndX);
												$startR = $StartX;
												$endR = $EndX;
												$startQ = $startQ + $right_len;
												$endQ = $endQ - $left_len;
											}
										}
										my $ref_len0 = $ref_len;
										my $query_len0 = $query_len;
										my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
										my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
										my $minR = ($startR < $endR) ? $startR : $endR;
										my $maxR = ($startR > $endR) ? $startR : $endR;
										$j++;
										if($j == 1)
										{
											# 初始化区域
											$region_Rmin = $minR;
											$region_Rmax = $maxR;
											$region_Qmin = $minQ;
											$region_Qmax = $maxQ;
											$chrRsave = $chrR;
											$chrQsave = $chrQ;
										}
										# —— 用“Query 的当前区域”做扩展窗口，筛掉距离过远的 Query 片段 ——
										my $Qgap_max = $region_Qmax + $gap_threshold;
										my $Qgap_min = $region_Qmin - $gap_threshold;
										# 若该 Query 片段完全落在扩展窗口之外，则跳过
										if ($maxQ < $Qgap_min || $minQ > $Qgap_max) {
											next;      # 丢掉与窗口不相交的片段
										}
										# —— 保留：并更新 R/Q 聚合区间 —— 
										$region_Rmin = $minR if $minR < $region_Rmin;
										$region_Rmax = $maxR if $maxR > $region_Rmax;
										$region_Qmin = $minQ if $minQ < $region_Qmin;
										$region_Qmax = $maxQ if $maxQ > $region_Qmax;
										my $new_keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
										my $new_keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
										$result_SYN{$Syn_num}->{$new_keyR}->{$new_keyQ} = $strand;
										my $len_regionR = abs($endR - $startR) + 1;
										my $len_regionQ = abs($endQ - $startQ) + 1;
										#print"TEST_1:$Syn_num\t$keyR\t$keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
										#print"TEST_2:$Syn_num\t$new_keyR\t$new_keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
									}
								}
							}
						}
					}
					# —— 若本轮没有任何片段被保留，跳过后续输出与链式更新 —— 
					if ($j == 0 || $region_Rmin == 1e12 || $region_Qmin == 1e12) {
						warn "Syn $Syn_num: no segments kept after gap filter on $GnameR/$GnameQ\n";
						next;
					}
					# —— 输出 —— 
					my $outX1 = commify($region_Rmin);
					my $outX2 = commify($region_Rmax);
					my $outX3 = commify($region_Qmin);
					my $outX4 = commify($region_Qmax);
					#print "$ref_genome:$GnameR: $chrRsave: [$outX1 - $outX2]\n";
					#print "$query_genome:$GnameQ: $chrQsave: [$outX3 - $outX4]\n\n";
					#if($genome_num==1)
					#$hash_region{$ref_genome_key} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
					#$hash_region{$query_genome_key} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
					#print"TEST5:$hash_region{$ref_genome}\n";
					#print"TEST5:$hash_region{$query_genome_key}\n";
					$hash_chr_region{$ref_genome}->{$Syn_num} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
					$hash_chr_region{$query_genome}->{$Syn_num} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
					# —— 链式更新（切换到下一基因组时让 ChrX/StartX/EndX 对应 Query 侧的区间）——
					$ChrX = $chrQsave;
					$StartX = $region_Qmin;
					$EndX = $region_Qmax;
				}
			}
		}
		# 反向查找部分,从大到小
		{
			my $chr_minR = 1e12;   # 初始化一个很大的数
			my $chr_maxR = -1;     # 初始化一个很小的数
			my $chrRsave;
			my $chrQsave;
			#my ($GnumX_trans, $GnameX_trans, $ChrX_trans, $StartX_trans, $EndX_trans);
			#反向查找部分
			$GnumX = $GnumX_trans;
			$GnameX = $GnameX_trans;
			$ChrX = $ChrX_trans;
			$StartX = $StartX_trans;
			$EndX = $EndX_trans;
			# 读取共线性信息文件
			foreach my $Syn_num(sort{$b<=>$a} keys %{$hash_syninfo_ref})
			{
				if($Syn_num < $GnumX)
				{
					$genome_num++;
					my $ref_genome   = $Syn_num + 1;
					my $query_genome = $Syn_num;
					my $lenR_max_start;
					my $lenR_max_end;
					my $GnameR = $hash_Ginfo_ref->{$ref_genome}->{'name'};
					my $GnameQ = $hash_Ginfo_ref->{$query_genome}->{'name'};
					my @arr_chrR = @{$aligned_order{$ref_genome}};
					my @arr_chrQ = @{$aligned_order{$query_genome}};
					# 建立 chr => index 的映射，方便快速查找下标
					my %posR = map { $arr_chrR[$_] => $_ } 0 .. $#arr_chrR;
					my %posQ = map { $arr_chrQ[$_] => $_ } 0 .. $#arr_chrQ;
					my $Syn_align = $hash_syninfo_ref->{$Syn_num}->{'align'};
					my $j = 0;
					my $chr_min = 1e12;   # 初始化一个很大的数
					my $chr_max = -1;     # 初始化一个很小的数
					open my $FL_align, "<", $Syn_align or die "Cannot open $Syn_align: $!";
					while(<$FL_align>)
					{
						chomp;
						next if /^#/;  # 跳过以 # 开头的注释行
						next if /^\s*$/;  # 跳过空行
						my @tem = split /\t/;
						my $chrR = $tem[3];
						my $chrQ = $tem[0];
						if($chrR eq $ChrX)
						{
							my ($startR, $endR, $startQ, $endQ);
							# 先检查 chr 是否存在于各自数组中
							next unless exists $posR{$chrR};
							next unless exists $posQ{$chrQ};
							# 索引位置必须相同
							if ($posR{$chrR} == $posQ{$chrQ}) {
								$j++;
								if($j == 1){$chrQsave = $chrR;}
								my $strandR = $chr_orient{$ref_genome}->{$chrR};
								my $strandQ = $chr_orient{$query_genome}->{$chrQ};
								$startR = $tem[4];
								$endR   = $tem[5];
								$startQ = $tem[1];
								$endQ   = $tem[2];
								my $strand = $tem[6];
								#my ($GnumX, $GnameX, $ChrX, $StartX, $EndX);
								#if ($StartX <= $endR and $startR <= $EndX)
								# case1: $startR 在 [$StartX, $EndX] 里面
								# case2: $endR   在 [$StartX, $EndX] 里面
								# case3: [$StartX, $EndX] 完全落在 [$startR, $endR] 里面
								if((($StartX <= $startR)and($startR <= $EndX)) or (($StartX <= $endR)and($endR <= $EndX)) or (($startR <= $StartX)and($EndX <= $endR)))
								{
									# 更新 chr_min 和 chr_max
									my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
									my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
									my $minR = ($startR < $endR) ? $startR : $endR;
									my $maxR = ($startR > $endR) ? $startR : $endR;
									my $chr_min0 = $chr_min;
									my $chr_max0 = $chr_max;
									my $chr_minR0 = $chr_minR;
									my $chr_maxR0 = $chr_maxR;
									#my ($chr_minR0, $chr_maxR0);
									$chr_min0 = $minQ if $minQ < $chr_min0;
									$chr_max0 = $maxQ if $maxQ > $chr_max0;
									$chr_minR0 = $minR if $minR < $chr_minR0;
									$chr_maxR0 = $maxR if $maxR > $chr_maxR0;
									#my $input_len = abs($EndX0 - $StartX0) + 1;             # 输入长度 1 Mb
									my $ref_len0 = abs($chr_maxR0 - $chr_minR0) + 1;
									my $query_len0 = abs($chr_max0 - $chr_min0) + 1;
									my $ref_len = abs($chr_maxR - $chr_minR) + 1;
									my $query_len = abs($chr_max - $chr_min) + 1;
									# 如果比对区间太大（比如超过输入的 2 倍），就跳过
									#next if $query_len0 > 2 * $ref_len0;
									$chr_min = $minQ if $minQ < $chr_min;
									$chr_max = $maxQ if $maxQ > $chr_max;
									$chr_minR = $minR if $minR < $chr_minR;
									$chr_maxR = $maxR if $maxR > $chr_maxR;
									my $keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
									my $keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
									#$hash_SYN{$Syn_num}->{$keyR}->{$keyQ} = $strand;
									#$hash_SYN_R{$Syn_num}->{$ref_genome}->{$chrR}->{$startR}->{$endR}=0;
									#print"-:$Syn_num\t$keyQ\t$keyR\t$strand\n";
									#print"-:$Syn_num\n";
									$hash_SYN{$Syn_num}->{$keyR}->{$keyQ} = $strand;
									#$hash_SYN_R{$Syn_num}->{$query_genome}->{$chrQ}->{$startQ}->{$endQ}=0;
									$hash_SYN_R{$Syn_num}->{$ref_genome}->{$chrR}->{$startR}->{$endR}=0;
								}
							}
						}
					}
					close $FL_align;
					$j = 0;
					my $region_Rmin = 1e12;
					my $region_Rmax = -1;
					my $region_Qmin = 1e12;
					my $region_Qmax = -1;
					my $hash_G1 = $hash_SYN_R{$Syn_num};
					foreach my $ref_genome_key (sort{$a<=>$b} keys %{$hash_G1})
					{
						my $hash_G2 = $hash_SYN_R{$Syn_num}->{$ref_genome_key};
						my $ref_len = 0;
						my $query_len = 0;
						foreach my $chrR (sort keys %{$hash_G2})
						{
							my $hash_G3 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR};
							foreach my $startR (sort{$a<=>$b} keys %{$hash_G3})
							{
								my $hash_G4 = $hash_SYN_R{$Syn_num}->{$ref_genome_key}->{$chrR}->{$startR};
								foreach my $endR (sort{$a<=>$b} keys %{$hash_G4})
								{
									my $keyR = "$ref_genome_key" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
									my $hash_G5 = $hash_SYN{$Syn_num}->{$keyR};
									foreach my $keyQ(sort keys %{$hash_G5})
									{
										my $strand = $hash_SYN{$Syn_num}->{$keyR}->{$keyQ};
										my ($query_genome_key, $chrQ, $startQ, $endQ) = split(/:/,$keyQ);
										#print"TEST2:$Syn_num\t$keyR\t$keyQ\t$strand\n";
										if($strand eq '+')
										{
											if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
											{
												# 完全在范围内，不变
											}
											elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
											{
												#裁掉reference左侧，query左侧
												my $startQ0 = $endQ - abs($endR - $StartX);
												$startR = $StartX;
												$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
											}
											elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
											{
												# 裁掉reference右侧，query右侧
												my $endQ0 = $startQ + abs($EndX - $startR);
												$endR = $EndX;
												$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
											}
											elsif(($startR <= $StartX)and($EndX <= $endR))
											{
												# 区间完全覆盖，取中间子段
												my $left_len = abs($StartX - $startR);
												my $right_len = abs($endR - $EndX);
												$startR = $StartX;
												$endR = $EndX;
												$startQ = $startQ + $left_len;
												$endQ = $endQ - $right_len;
											}
										}
										elsif($strand eq '-')
										{
											if(($StartX <= $startR)and($startR <= $EndX)and($StartX <= $endR)and($endR <= $EndX))
											{
												# 完全在范围内，不变
											}
											elsif(($StartX <= $endR)and($endR <= $EndX)and($startR < $StartX))
											{
												#裁掉reference左侧，query右侧
												my $endQ0 = $startQ + abs($endR - $StartX);
												$startR = $StartX;
												$endQ = ($endQ0 < $endQ) ? $endQ0 : $endQ;
											}
											elsif(($StartX <= $startR)and($startR <= $EndX)and($EndX < $endR))
											{
												# 裁掉reference右侧，query左侧
												my $startQ0 = $endQ - abs($EndX - $startR);
												$endR = $EndX;
												$startQ = ($startQ0 > $startQ) ? $startQ0 : $startQ;
											}
											elsif(($startR <= $StartX)and($EndX <= $endR))
											{
												# 区间完全覆盖，取中间子段
												my $left_len = abs($StartX - $startR);
												my $right_len = abs($endR - $EndX);
												$startR = $StartX;
												$endR = $EndX;
												$startQ = $startQ + $right_len;
												$endQ = $endQ - $left_len;
											}
										}
										my $ref_len0 = $ref_len;
										my $query_len0 = $query_len;
										my $minQ = ($startQ < $endQ) ? $startQ : $endQ;
										my $maxQ = ($startQ > $endQ) ? $startQ : $endQ;
										my $minR = ($startR < $endR) ? $startR : $endR;
										my $maxR = ($startR > $endR) ? $startR : $endR;
										$j++;
										if($j == 1)
										{
											# 初始化区域
											$region_Rmin = $minR;
											$region_Rmax = $maxR;
											$region_Qmin = $minQ;
											$region_Qmax = $maxQ;
											$chrRsave = $chrR;
											$chrQsave = $chrQ;
										}
										# —— 用“Query 的当前区域”做扩展窗口，筛掉距离过远的 Query 片段 ——
										my $Qgap_max = $region_Qmax + $gap_threshold;
										my $Qgap_min = $region_Qmin - $gap_threshold;
										# 若该 Query 片段完全落在扩展窗口之外，则跳过
										if ($maxQ < $Qgap_min || $minQ > $Qgap_max) {
											next;      # 丢掉与窗口不相交的片段
										}
										# —— 保留：并更新 R/Q 聚合区间 —— 
										$region_Rmin = $minR if $minR < $region_Rmin;
										$region_Rmax = $maxR if $maxR > $region_Rmax;
										$region_Qmin = $minQ if $minQ < $region_Qmin;
										$region_Qmax = $maxQ if $maxQ > $region_Qmax;
										my $new_keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
										my $new_keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
										#$result_SYN{$Syn_num}->{$new_keyR}->{$new_keyQ} = $strand;
										$result_SYN{$Syn_num}->{$new_keyQ}->{$new_keyR} = $strand;
										my $len_regionR = abs($endR - $startR) + 1;
										my $len_regionQ = abs($endQ - $startQ) + 1;
										#print"TEST_1:$Syn_num\t$keyR\t$keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
										#print"TEST_2:$Syn_num\t$new_keyR\t$new_keyQ\t$strand\tR:Q: $len_regionR\t$len_regionQ\n";
									}
								}
							}
						}
					}
					# —— 若本轮没有任何片段被保留，跳过后续输出与链式更新 —— 
					if ($j == 0 || $region_Rmin == 1e12 || $region_Qmin == 1e12) {
						warn "Syn $Syn_num: no segments kept after gap filter on $GnameR/$GnameQ\n";
						next;
					}
					# —— 输出 —— 
					my $outX1 = commify($region_Rmin);
					my $outX2 = commify($region_Rmax);
					my $outX3 = commify($region_Qmin);
					my $outX4 = commify($region_Qmax);
					#print "$query_genome:$GnameQ: $chrQsave: [$outX3 - $outX4]\n\n";
					#print "$ref_genome:$GnameR: $chrRsave: [$outX1 - $outX2]\n";
					#if($genome_num==1)
					#$hash_region{$ref_genome_key} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
					#$hash_region{$query_genome_key} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
					#print"TEST5:$hash_region{$ref_genome}\n";
					#print"TEST5:$hash_region{$query_genome_key}\n";
					$hash_chr_region{$ref_genome}->{$Syn_num} = "$GnameR" . '_:_' . "$chrRsave" . '_:_' . "$region_Rmin" . '_:_' . "$region_Rmax";
					$hash_chr_region{$query_genome}->{$Syn_num} = "$GnameQ" . '_:_' . "$chrQsave" . '_:_' . "$region_Qmin" . '_:_' . "$region_Qmax";
					# —— 链式更新（切换到下一基因组时让 ChrX/StartX/EndX 对应 Query 侧的区间）——
					$ChrX = $chrQsave;
					$StartX = $region_Qmin;
					$EndX = $region_Qmax;
				}
			}
		}

		foreach my $GNUM (sort{$a<=>$b} keys %hash_chr_region)
		{
			my $HASHG1 = $hash_chr_region{$GNUM};
			my @arr_region;
			foreach my $Syn_num (sort{$a<=>$b} keys %{$HASHG1})
			{
				my $key_region = $hash_chr_region{$GNUM}->{$Syn_num};
				push(@arr_region, $key_region);
			}
			my $count = scalar(@arr_region);
			if ($count == 0) {
				warn "Warning: no regions for genome $GNUM\n";
				next;
			}
			elsif($count == 1)
			{
				$hash_region{$GNUM} = $arr_region[0];
			}
			elsif($count == 2)
			{
				my ($Gname1, $chr1, $region_min1, $region_max1) = split(/_:_/, $arr_region[0]);
				my ($Gname2, $chr2, $region_min2, $region_max2) = split(/_:_/, $arr_region[1]);
				my $minX = ($region_min1 < $region_min2) ? $region_min1 : $region_min2;
				my $maxX = ($region_max1 > $region_max2) ? $region_max1 : $region_max2;
				$hash_region{$GNUM} = "$Gname1" . '_:_' . "$chr1" . '_:_' . "$minX" . '_:_' . "$maxX";
			}
		}
	}

	 # my ($GnumX, $GnameX, $ChrX, $StartX, $EndX);
	 #$hash_region{$GnumX} = "$GnameX" . '_:_' . "$ChrX" . '_:_' . "$StartX" . '_:_' . "$EndX";
	 #if(0 == 1)
	 {
		my $region_len_max = 0;
		my $region_len_min = 0;
		my $genome_len = 0;
		my $gname_max_num0 = 0;
		my $chrname_max_num0 = 0;
		foreach my $Gnum (sort{$a<=>$b} keys %hash_region)
		{
			#my ($StartX, $EndX) = split(/-/, $startend);
			my $keyx0 = $hash_region{$Gnum};
			my ($gnamex0, $chrx0, $startx0, $endx0) = split(/_:_/, $keyx0);
			my $chr_len = abs($endx0 - $startx0) + 1;
			#print "$Gnum:$gnamex0:$chrx0:$startx0:$endx0:$chr_len\n";
			# 更新最大值
			$region_len_max = $chr_len if $chr_len > $region_len_max;
			# 更新最小值
			if (!defined($region_len_min) || $chr_len < $region_len_min) {
				$region_len_min = $chr_len;
			}
			# 更新基因组名称最大字符串的字符数目
			my $Glen = length($gnamex0);
			$gname_max_num0 = $Glen if $Glen > $gname_max_num0;
			# 更新染色体名称最大字符串的字符数目
			my $Chrlen = length($hash_chrGAI{$Gnum}->{$chrx0});
			$chrname_max_num0 = $Chrlen if $Chrlen > $chrname_max_num0;
		}
		$gname_max_num0 = estimate_svg_text_width($gname_max_num0);
		$chrname_max_num0 = estimate_svg_text_width($chrname_max_num0);
		$SVG_x = $SVG_x_left + $gname_max_num0 + $chrname_max_num0 + 2;
		my $tel_width = 0;
		#if (exists $config_ref->{'telomere_info'}) {$SVG_x += ($ChrHight / 2);$tel_width = ($ChrHight / 2);}
		$scale = $region_len_max/$SVG_main;
		#print"\$scale:$scale\n";
		my $hash_gene_height_ref;
		my $gene_info_ref;
		my $GHM = 0;
		if (exists $config_ref->{'show_region'}->{'gene_list'})
		{
			($hash_gene_height_ref, $gene_info_ref) = read_gene_structure($gene_list, \%hash_Ginfo, \%hash_region, $genome_num);
			foreach my $Gnum (sort{$a<=>$b} keys %hash_Ginfo)
			{
				my $GH = $hash_gene_height_ref->{$Gnum};
				$GHM += $GH;
			}
		}
		else
		{
			foreach my $Gnum (sort{$a<=>$b} keys %hash_Ginfo)
			{
				my $chr_tags = $hash_Ginfo{$Gnum}->{'tags'};
				if (defined $chr_tags) 
				{
					if ($chr_tags =~ /height:\s*['"]?([\d.]+)['"]?/){$ChrHight = $1;}
					if ($chr_tags =~ /opacity:\s*['"]?([\d.]+)['"]?/){$Chropacity = $1;}
					if ($chr_tags =~ /color:\s*['"]?([^'";]+)['"]?/){$Chrcolor = $1;}
				}
				my $GH = $ChrHight;
				$GHM += $GH;
			}
		}
		#Canvas size
		my $SVG1= SVG -> new();
		my $SVG1_canvas_w = sprintf("%.0f", $SVG_main + $SVG_x + $SVG_x_right + 15 );
		my $SVG1_canvas_h = sprintf("%.0f", ($Chrtop + $Chrdottom) * ($genome_num + 1) + $synteny_height * ($genome_num + 1) + $SVG_x_top + $GHM);
		$SVG1= SVG -> new(width => $SVG1_canvas_w . 'mm', height   => $SVG1_canvas_h . 'mm', viewBox => "0 0 $SVG1_canvas_w $SVG1_canvas_h");

		#绘制共线性块
		draw_syn_region($SVG1,\%result_SYN,\%hash_Ginfo,\%hash_region,$syntent_type,$genome_num, $hash_gene_height_ref);
		#绘制染色体块及刻度线
		draw_chr_region($SVG1,\%hash_Ginfo,\%hash_region,$genome_num, $hash_gene_height_ref);
		if (exists $config_ref->{'show_region'}->{'gene_list'})
		{
			draw_gene_structure($SVG1, \%hash_Ginfo, \%hash_region, $hash_gene_height_ref, $gene_info_ref);
		}

		if (exists $config_ref->{'anno_info'}) {
			#绘制注释信息
			my $anno_info_raw = $config_ref->{'anno_info'};
			my %anno_info_raw = %$anno_info_raw;
			draw_anno_block($SVG1,\%anno_info_raw,\%hash_Ginfo,$genome_num);
		}
		my $svg_file = $config_ref->{'save_info'}->{'savefig1'};
		my $svg_pdf = 1;
		if($svg_file =~ /\.pdf$/i){ $svg_file =~ s/\.pdf$/.svg/i; $svg_pdf = 2;}
		if($svg_file =~ /\.png$/i){ $svg_file =~ s/\.png$/.svg/i; $svg_pdf = 3;}
		elsif($svg_file =~ /\.svg$/i){}
		else{$svg_file .= '.svg'; $svg_pdf = 2;}
		# 输出绘图文件
		open my $svg_fh, '>', $svg_file or die "无法写入 $svg_file: $!";
		print $svg_fh $SVG1->xmlify(), "\n";
		close $svg_fh;
		print"\ndrawing_region:\nCanvas width: $SVG1_canvas_w mm\n";
		print"Canvas height: $SVG1_canvas_h mm\n";
		my $pdf_file = '';
		if(($svg_pdf == 2)or($svg_pdf == 3))
		{
			# 先生成目标文件名
			my $tmp_pdf = $svg_file;
			if($svg_pdf == 2){$tmp_pdf =~ s/\.svg$/.pdf/i;}
			elsif($svg_pdf == 3){$tmp_pdf =~ s/\.svg$/.png/i;}
			# 调用 CairoSVG 转换
			if (system("cairosvg $svg_file -o $tmp_pdf") == 0) {
				# 转换成功时，才更新 $pdf_file
				$pdf_file = $tmp_pdf;
			}
			else {
				#warn "转换失败：$!";
				warn "Conversion failed: $!";
			}
			return $tmp_pdf;
		}
		if(0){
			$svg_file =~ s/\.pdf$/.svg/;

			# 输出绘图文件
			open my $svg_fh, '>', $svg_file or die "无法写入 $svg_file: $!";
			print $svg_fh $SVG1->xmlify(), "\n";
			close $svg_fh;

			# 生成对应的 PDF 文件名
			(my $pdf_file = $svg_file) =~ s/\.svg$/.pdf/;

			# 调用 CairoSVG 转换
			system("cairosvg $svg_file -o $pdf_file") == 0
				or die "转换失败：$!";
		}
	}
	print "\ndrawing_region:--OK!--\n";
}

sub read_gene_structure {
     my ($gene_list, $hash_Ginfo_ref, $hash_region_ref, $genome_num_ref) = @_;
	 my %gene_info;
	 foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	 {
		my $hash_regionX = $hash_region_ref->{$Gnum};
		my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		my ($GnameX, $ChrX, $StartX, $EndX) = split(/_:_/,$hash_regionX);
		my $chr_len = abs($EndX - $StartX) + 1;
		my $chr_width = $chr_len / $scale;
		open my $FL_gene_anno, "<", $gene_list or die "Cannot open $gene_list: $!";
		while(<$FL_gene_anno>) {
			chomp;
			next if /^#/ || /^\s*$/;
			my ($gnum, $file_anno) = split /\t/;
			# -----------------------
			# 读取注释文件（single $file_anno），两阶段处理：先收集，再聚合
			# -----------------------
			my (%genes, %mRNAs, %children);
			my $j = 0;
			open my $FL_gene_annoX, "<", $file_anno or die "Cannot open $file_anno: $!";
			while(<$FL_gene_annoX>) {
				chomp;
				next if /^#/ || /^\s*$/;
				my ($chr, $identity, $type, $start, $end, $score, $strand, $phase, $attr) = split /\t/;
				$type = lc($type);
				next unless defined $chr && $chr eq $ChrX;  # 只处理同染色体的行

				# 解析 attr 为 hash，支持 ID=..;Parent=..; 等
				my %attr;
				while ($attr =~ /([^=;]+)=([^;]+)/g) {
					$attr{$1} = $2;
				}

				if ($type eq 'gene') {
					my $id = $attr{ID} // next;
					$genes{$id} = {
						start => $start+0,
						end   => $end+0,
						strand=> $strand,
						chr   => $chr,
						info  => "$chr:$start:$end:$strand",
					};
				}
				#elsif ($type =~ /^(mRNA|transcript)$/) {
				elsif ($type =~ /^(mrna|transcript)$/) {
					#$j = 0;
					my $id = $attr{ID} // next;
					my $parent = $attr{Parent} // '';
					$mRNAs{$id} = {
						type   => $type,
						parent => $parent,
						start  => $start+0,
						end    => $end+0,
						strand => $strand,
						chr    => $chr,
						info   => "$chr:$start:$end:$strand",
					};
				}
				#elsif ($type =~ /^(CDS|five_prime_UTR|three_prime_UTR)$/) {
				elsif ($type =~ /^(cds|five_prime_utr|three_prime_utr)$/) {
					$j ++;
					my $parent = $attr{Parent} // next;
					my $id_make = "$parent" . '-' . "$type" . '-' . "$j";
					my $id = $id_make;
					# Parent 可能是逗号分隔的多个 ID
					#for my $pm (split /,/, $parent) {
						#push @{$children{$pm}}, {
						$children{$parent}{$id} = {
							type   => $type,
							chr    => $chr,
							start  => $start+0,
							end    => $end+0,
							strand => $strand,
							info   => "$type:$chr:$start:$end:$strand",
						};
					#}
				}
			}
			close $FL_gene_annoX;

			# -----------------------
			# 聚合：先以 gene 为主，附加 mRNA -> children
			# -----------------------
			# 1) genes 与区域有重叠则保留
			foreach my $gid (sort keys %genes) {
				my $g = $genes{$gid};
				if ($g->{end} >= $StartX && $g->{start} <= $EndX) {   # 重叠判断
					# 可选：把 gene 的 info 裁剪到区间内（绘图时常用）
					my $g_s = $g->{start} < $StartX ? $StartX : $g->{start};
					my $g_e = $g->{end}   > $EndX   ? $EndX   : $g->{end};
					$gene_info{$Gnum}{$gid}{info} = "$ChrX:$g_s:$g_e:$g->{strand}";
					$gene_info{$Gnum}{$gid}{orig_info} = $g->{info}; # 保留原始坐标以备查
					#print"gene:$Gname:$gid\t$gene_info{$Gnum}{$gid}{orig_info}\n";

					# 附上属于该 gene 的所有 mRNA（parent 字段可能包含多个 parent id）
					foreach my $mrna_id (grep { defined $mRNAs{$_} && $mRNAs{$_}{parent} =~ /\b\Q$gid\E\b/ } keys %mRNAs) {
						my $mr = $mRNAs{$mrna_id};
						$gene_info{$Gnum}{$gid}{mRNAs}{$mrna_id}{info} = $mr->{info};
						#print"$Gname:$mRNAs{$mrna_id}{type}:$mrna_id\t$mRNAs{$mrna_id}{info}\n";
						foreach my $children_id (sort keys %{$children{$mrna_id}})
						{
							#push @{$gene_info{$Gnum}{$gid}{mRNAs}{$mrna_id}{children}}, $$children{$mrna_id};
							$gene_info{$Gnum}{$gid}{mRNAs}{$mrna_id}{children}{$children_id} = $children{$mrna_id}{$children_id};
							#print"$Gname:$children{$mrna_id}{$children_id}{type}:$children_id\t$children{$mrna_id}{$children_id}{info}\n";
						}
					}
				}
			}
		}
		close $FL_gene_anno;
	 }
	 my %hash_gene_height;
	 foreach my $Gnum (sort{$a<=>$b} keys %gene_info)
	 {
		my $region_height_max = 0;
		foreach my $gene_id (sort keys %{$gene_info{$Gnum}})
		{
			my $mrna_count = scalar keys %{ $gene_info{$Gnum}{$gene_id}{mRNAs} };
			my $heightX = 2;
			my $heightgap = 0.5;
			my $HEIGHTX = $heightX + $heightgap;
			my $gene_height = $heightX * $mrna_count + $heightgap * ($mrna_count - 1) + 5 + 1;
			$region_height_max = ($region_height_max > $gene_height) ? $region_height_max : $gene_height;
		}
		$hash_gene_height{$Gnum} = $region_height_max;
	 }
	 return (\%hash_gene_height, \%gene_info);
}

sub draw_gene_structure {
	my ($SVG1, $hash_Ginfo_ref, $hash_region_ref, $hash_gene_height_ref, $gene_info_ref) = @_;
	my $gene_height_merge = 0;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		my $hash_regionX = $hash_region_ref->{$Gnum};
		my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		my ($GnameX, $ChrX, $StartX, $EndX) = split(/_:_/,$hash_regionX);
		my $chr_len = abs($EndX - $StartX) + 1;
		my $chr_width = $chr_len / $scale;
		my $GH = $hash_gene_height_ref->{$Gnum};
		foreach my $gene_id (sort keys %{$gene_info_ref->{$Gnum}})
		{
			my $Count = 0;
			#$Count++;
			my $mrna_count = scalar keys %{ $gene_info_ref->{$Gnum}{$gene_id}{mRNAs} };
			my $gene_INFO = $gene_info_ref->{$Gnum}{$gene_id}{orig_info};
			my ($Gchr, $Gstart, $Gend, $Gstrand) = split(/:/, $gene_INFO);
			my $rect_x = $SVG_x + ($SVG_main - $chr_width)/2;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($Gnum - 1) * ($Chrtop + $Chrdottom + $synteny_height) + 1 + $gene_height_merge;
			#my ($GnameX, $ChrX, $StartX, $EndX) = split(/_:_/,$hash_regionX);
			$Gstart = ($Gstart < $StartX) ? $StartX : $Gstart;
			$Gend = ($Gend > $EndX) ? $EndX : $Gend;
			my $Gstart_scale = ($Gstart - $StartX) / $scale;
			my $Gend_scale = ($Gend - $StartX) / $scale;
			my $Gene_min = ($Gstart_scale < $Gend_scale) ? $Gstart_scale : $Gend_scale;
			my $Gene_max = ($Gstart_scale > $Gend_scale) ? $Gstart_scale : $Gend_scale;
			my $Gene_len = (abs($Gend - $Gstart) + 1) / $scale;
			my $heightX = 2;
			my $heightgap = 0.5;
			my $HEIGHTX = $heightX + $heightgap;
			my $gene_height = $heightX * $mrna_count + $heightgap * ($mrna_count - 1) + 5;
			if(0 == 1){
				$SVG1 -> rect(
					 x => ($rect_x + $Gene_min),
					 y => ($rect_y),
					 width => $Gene_len,
					 height =>  $gene_height,
					 style=>{
						 'fill'=>'#FFFFFF',
						 'stroke'=>'#FFFFFF',
						 'stroke-width'=>'0',
					}
				);
			}
			my $gene_id_height = 0;
			foreach my $mrna_id (sort keys %{$gene_info_ref->{$Gnum}{$gene_id}{mRNAs}})
			{
				my $mrna_INFO = $gene_info_ref->{$Gnum}{$gene_id}{mRNAs}{$mrna_id}{info};
				my ($Mchr, $Mstart, $Mend, $Mstrand) = split(/:/, $mrna_INFO);
				#$Mstart = ($Mstart < $StartX) ? $StartX : $Mstart;
				my $polygon_off = 1;
				if($Mstart < $StartX){$Mstart = $StartX;$polygon_off = 0;}
				$Mend = ($Mend > $EndX) ? $EndX : $Mend;
				my $Mstart_scale = ($Mstart - $StartX) / $scale;
				my $Mend_scale = ($Mend - $StartX) / $scale;
				my $Mrna_min = ($Mstart_scale < $Mend_scale) ? $Mstart_scale : $Mend_scale;
				my $Mrna_max = ($Mstart_scale > $Mend_scale) ? $Mstart_scale : $Mend_scale;
				my $Mrna_len = (abs($Mend - $Mstart) + 1) / $scale;
				my $Mrna_height = $heightX;
				if($Mstrand eq '+')
				{
					$SVG1->line(
						x1 => ($rect_x + $Mrna_min), y1 => $rect_y + $Mrna_height/2 + $Count * $HEIGHTX,
						x2 => ($rect_x + $Mrna_max + 1), y2 => $rect_y + $Mrna_height/2 + $Count * $HEIGHTX,
						style => { stroke => 'black', 'stroke-width' => 0.2 }
					);
					my $X1 = $rect_x + $Mrna_max + 1;
					my $Y1 = $rect_y - 0.5 + $Mrna_height/2 + $Count * $HEIGHTX;
					my $X2 = $rect_x + $Mrna_max + 1;
					my $Y2 = $rect_y + 0.5 + $Mrna_height/2 + $Count * $HEIGHTX;
					my $X3 = $rect_x + $Mrna_max + 2;
					my $Y3 = $rect_y + $Mrna_height/2 + $Count * $HEIGHTX;
					if($polygon_off == 1)
					{
						$SVG1->polygon(
							 points=>"$X1,$Y1 $X2,$Y2  $X3,$Y3",
							 style=>{
								 'fill'=>'block',
								 'stroke'=>'black',
								 'opacity'=>'1',
								 'stroke-width'=>'0',
							}
						);
					}
				}
				elsif($Gstrand eq '-')
				{
					$SVG1->line(
						x1 => ($rect_x + $Mrna_min - 1), y1 => $rect_y + $Mrna_height/2 + $Count * $HEIGHTX,
						x2 => ($rect_x + $Mrna_max), y2 => $rect_y + $Mrna_height/2 + $Count * $HEIGHTX,
						style => { stroke => 'black', 'stroke-width' => 0.2 }
					);
					my $X1 = $rect_x + $Mrna_min - 1;
					my $Y1 = $rect_y - 0.5 + $Mrna_height/2 + $Count * $HEIGHTX;
					my $X2 = $rect_x + $Mrna_min - 1;
					my $Y2 = $rect_y + 0.5 + $Mrna_height/2 + $Count * $HEIGHTX;
					my $X3 = $rect_x + $Mrna_min - 2;
					my $Y3 = $rect_y + $Mrna_height/2 + $Count * $HEIGHTX;
					if($polygon_off == 1)
					{
						$SVG1->polygon(
							 points=>"$X1,$Y1 $X2,$Y2  $X3,$Y3",
							 style=>{
								 'fill'=>'block',
								 'stroke'=>'black',
								 'opacity'=>'1',
								 'stroke-width'=>'0',
							}
						);
					}
				}
				
				foreach my $children_id (sort keys %{$gene_info_ref->{$Gnum}{$gene_id}{mRNAs}{$mrna_id}{children}})
				{
					my $children_INFO = $gene_info_ref->{$Gnum}{$gene_id}{mRNAs}{$mrna_id}{children}{$children_id}{info};
					my ($childtype, $childchr, $Cstart, $Cend, $Cstrand) = split(/:/, $children_INFO);
					# 不相交，则直接跳过
					next if $Cend   < $StartX;
					next if $Cstart > $EndX;

					# 相交，则裁剪到窗口
					$Cstart = $Cstart < $StartX ? $StartX : $Cstart;
					$Cend   = $Cend   > $EndX   ? $EndX   : $Cend;

					# 如果长度为 0，则跳过
					my $Child_len0 = abs($Cstart - $Cend);
					next if $Child_len0 == 0;
					my $childstart_scale = ($Cstart - $StartX) / $scale;
					my $childend_scale = ($Cend - $StartX) / $scale;
					my $child_min = ($childstart_scale < $childend_scale) ? $childstart_scale : $childend_scale;
					my $child_max = ($childstart_scale > $childend_scale) ? $childstart_scale : $childend_scale;
					my $child_len = (abs($Cend - $Cstart) + 1) / $scale;
					my $Ctype = lc($childtype);
					my $C_height = $heightX;
					my $C_color = '#DAA520';  #357089
					if($Ctype eq 'cds'){}
					elsif(($Ctype eq 'five_prime_utr')or($Ctype eq 'three_prime_utr'))
					{
						$C_height = $heightX - 1;
						$C_color = '#357089';  
					}
					$SVG1 -> rect(
						 x => ($rect_x + $child_min),
						 y => ($rect_y + ($Mrna_height - $C_height)/2  + $Count * $HEIGHTX),
						 width => $child_len,
						 height =>  $C_height,
						 style=>{
							 'fill'=>$C_color,
							 'stroke'=>'#FFFFFF',
							 'stroke-width'=>'0',
						}
					);
				}
			$Count++;
			}
			$gene_id_height = $rect_y + $Count * $HEIGHTX + 3.5;
			$SVG1 -> text(
				 x => ($rect_x + $Gene_min),
				 y => ($gene_id_height),
				 style => {
					'font-family' => 'Arial', #"Courier",
					'stroke'      => 'none',
					'font-size'   => '4',
					'text-anchor' => 'start',   # 可为 start | middle | end
				}
			)->cdata("$gene_id");
		}
		$gene_height_merge += $GH;
	}
}

#绘制给定染色体区域块
sub draw_chr_region {
	my ($SVG1, $hash_Ginfo_ref, $hash_region_ref, $genome_num_ref, $hash_gene_height_ref) = @_;
	#记录颜色
	my $gene_height_merge = 0;
	foreach my $Gnum (sort { $a <=> $b } keys %aligned_order)
	{
		my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		my $chr_tags = $hash_Ginfo_ref->{$Gnum}->{'tags'} // "height:5;opacity:0.8;color:'#39A5D6';"; #lw:1.5;color:#FF0000;opacity:1
		my $GH = $hash_gene_height_ref->{$Gnum};
		if (defined $chr_tags) 
		{
			if ($chr_tags =~ /height:\s*['"]?([\d.]+)['"]?/){$ChrHight = $1;}
			if ($chr_tags =~ /opacity:\s*['"]?([\d.]+)['"]?/){$Chropacity = $1;}
			if ($chr_tags =~ /color:\s*['"]?([^'";]+)['"]?/){$Chrcolor = $1;}
		}
		
		my $hash_regionX = $hash_region_ref->{$Gnum};
		my ($GnameX, $ChrX, $StartX, $EndX) = split(/_:_/,$hash_regionX);
		my $chr_len = abs($EndX - $StartX) + 1;
		my $chr_lenout = commify($chr_len);
		print "$Gnum\t$GnameX\t$ChrX\t$StartX\t$EndX\t$chr_lenout\n";
		my $chr_width = $chr_len / $scale;
		my $rect_x = $SVG_x + ($SVG_main - $chr_width)/2;
		my $rect_y = $SVG_y + 2 + $Chrtop + ($Gnum - 1) * ($Chrtop + $Chrdottom + $synteny_height) + $gene_height_merge;
		draw_scale_axis_region($SVG1, $StartX, $EndX, $rect_x, $rect_y - 2 - $Chrtop);
		$gene_height_merge += $GH;
		##### chromosome region
		
		#my $chr_r = $ChrHight/2;
		$SVG1 -> rect(
			 x => ($rect_x),
			 y => ($rect_y),
			 width => $chr_width,
			 height => $GH,
			 style=>{
				 'fill'=>'#FFFFFF',
				 'stroke'=>'#FFFFFF',
				 'stroke-width'=>'0.1',
			}
		);
		$SVG1 -> rect(
			 x => ($rect_x),
			 y => ($rect_y),
			 width => $chr_width,
			 height => $GH,
			 style=>{
				 'fill'=>"$Chrcolor",
				 'fill-opacity'   => "$Chropacity",
				 'stroke'=>'black',
				 'stroke-width'=>'0.1',
			}
		);
		my $dot = "&#183;";  # HTML实体形式（中点字符）
		my $out_start = commify($StartX);
		my $out_end = commify($StartX);
		#my $NAME_Gchr = "$Gname" . $dot . "$hash_chrGAI{$Gnum}->{$ChrX}" . "$out_start" . '-' . "$out_end";
		my $NAME_Gchr = "$Gname" . $dot . "$hash_chrGAI{$Gnum}->{$ChrX}";
		my $X1 = ($rect_x - 2);
		$SVG1 -> text(
			 x => $X1,
			 y => ($rect_y + $GH/2 + 1),
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'end',   # 可为 start | middle | end
			}
		)->cdata("$NAME_Gchr");
	}	
}
## 绘制局部的刻度尺
sub draw_scale_axis_region {
    my ($SVG1, $StartX, $EndX, $scale_X, $scale_Y) = @_;

    # 参数检查 & 默认
    die "StartX > EndX\n" if !defined $StartX || !defined $EndX || $StartX > $EndX;
    #my $bp_per_px = defined $bp_per_px_param ? $bp_per_px_param : (defined $scale ? $scale : 1000);
	my $bp_per_px = $scale;
    $bp_per_px = 1 if $bp_per_px <= 0;

    my $region_len = abs($EndX - $StartX) + 1;
    my $t_postfix = "Mb";
    my $valueSpan = 5_000_000;    # 默认主刻度间隔
    my ($scaleXX, $scaleYY);

    # 自动选择 valueSpan 与单位（与之前逻辑一致）
    if    ($region_len >= 1_000_000_000) { $valueSpan = 100_000_000;  $scaleYY = 1;  $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 50_000_000)     { $valueSpan = 10_000_000;  $scaleYY = 10; $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 5_000_000)      { $valueSpan = 1_000_000;   $scaleYY = 1;  $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 1_000_000)      { $valueSpan = 1_000_000;   $scaleYY = 1;  $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 100_000)        { $valueSpan = 50_000;      $scaleYY = 50; $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 10_000)         { $valueSpan = 5_000;       $scaleYY = 5;  $scaleXX = $valueSpan/5;  }
    elsif ($region_len >= 1_000)          { $valueSpan = 1_000;       $scaleYY = 1;  $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 100)            { $valueSpan = 50;          $scaleYY = 50; $scaleXX = $valueSpan/10; }
    elsif ($region_len >= 10)             { $valueSpan = 5;           $scaleYY = 5;  $scaleXX = 1; }
    else                                  { $valueSpan = 1;           $scaleYY = 1;  $scaleXX = 1; }
	
	my $maxX1 = ($StartX > $EndX) ? $StartX : $EndX;
    if    ($maxX1 >= 1_000_000_000)  { $t_postfix = "Gb";}
    elsif ($maxX1 >= 50_000_000)     { $t_postfix = "Mb";}
    elsif ($maxX1 >= 5_000_000)      { $t_postfix = "Mb";}
    elsif ($maxX1 >= 1_000_000)      { $t_postfix = "Mb";}
    elsif ($maxX1 >= 100_000)        { $t_postfix = "Kb";}
    elsif ($maxX1 >= 10_000)         { $t_postfix = "Kb";}
    elsif ($maxX1 >= 1_000)          { $t_postfix = "Kb";}
    elsif ($maxX1 >= 100)            { $t_postfix = "bp";}
    elsif ($maxX1 >= 10)             { $t_postfix = "bp";}
    else                             { $t_postfix = "bp";}
    # 次刻度数（在两个主刻度之间划分多少次刻度）
    # my $minor_count = 10;
	my $minor_count = $scaleYY;
    #my $minor_step = $valueSpan / $minor_count;
	my $minor_step = $scaleXX;
    $minor_step = 1 if $minor_step < 1;

    # 确定从哪个次刻度开始（向下对齐）
    my $first_minor = int($StartX / $minor_step) * $minor_step;

    # 绘制次刻度与主刻度（循环次刻度，但只绘在 [StartX, EndX] 区间内）
    for (my $tick = $first_minor; $tick <= $EndX; $tick += $minor_step) {
        next if $tick < $StartX;
        # 精确到整数坐标（避免浮点模运算问题）
        my $tick_i = int($tick + 0.5);
        my $is_major = ($tick_i % $valueSpan == 0) ? 1 : 0;

        # 计算像素 x（相对于 StartX）
        my $xpx = $scale_X + ($tick - $StartX) / $bp_per_px;

        if ($is_major) {
            # 主刻度：画长线并加标签（格式化标签）
            my $label;
			if    ($t_postfix eq 'Gb') { $label = ($tick / 1e9) . "Gb"; }
			elsif ($t_postfix eq 'Mb') { $label = ($tick / 1e6) . "Mb"; }
			elsif ($t_postfix eq 'Kb') { $label = ($tick / 1e3) . "Kb"; }
			else                       { $label = $tick . "bp"; }
			# 去掉末尾多余的 .0 / 0
			$label =~ s/(\.\d*?)0+$/$1/;
			$label =~ s/\.$//;
            $SVG1->line(
                x1 => $xpx, y1 => ($scale_Y - 6),
                x2 => $xpx, y2 => $scale_Y,
                style => { stroke => 'black', 'stroke-width' => 0.2 }
            );
            $SVG1->text(
                x => $xpx, y => ($scale_Y - 8),
                style => { 'font-size' => 4, 'text-anchor' => 'middle', 'font-family' => 'Arial' }
            )->cdata($label);
        } else {
            # 次刻度：短线
            $SVG1->line(
                x1 => $xpx, y1 => ($scale_Y - 2),
                x2 => $xpx, y2 => $scale_Y,
                style => { stroke => 'black', 'stroke-width' => 0.12 }
            );
        }
    }

    # 若区间内没有任何“整数主刻度”（例如 StartX..EndX 比 valueSpan 小且不跨主刻度边界），
    # 那就至少在起点/终点画标签以保持可读性
    my $first_major = int( ($StartX + $valueSpan - 1) / $valueSpan ) * $valueSpan;
    if ($first_major > $EndX) {
        # 画起点和终点（标签）
        for my $tick ($StartX, $EndX) {
            my $xpx = $scale_X + ($tick - $StartX) / $bp_per_px;
            my $label;
            if ($t_postfix eq 'Gb') { $label = sprintf("%.2fGb", $tick / 1e9); }
            elsif ($t_postfix eq 'Mb') { $label = sprintf("%.2fMb", $tick / 1e6); }
            elsif ($t_postfix eq 'Kb') { $label = sprintf("%.0fKb", $tick / 1e3); }
            else { $label = sprintf("%dbp", $tick); }

            $SVG1->line(x1=>$xpx, y1=>($scale_Y - 6), x2=>$xpx, y2=>$scale_Y, style=>{stroke=>'black','stroke-width'=>0.2});
            $SVG1->text(x=>$xpx, y=>($scale_Y - 8), style=>{'font-size'=>4, 'text-anchor'=>'middle'})->cdata($label);
        }
    }

    # 横轴（整条）
    my $axis_len_px = $region_len / $bp_per_px;
    $SVG1->line(
        x1 => $scale_X, y1 => $scale_Y,
        x2 => ($scale_X + $axis_len_px), y2 => $scale_Y,
        style => { stroke => 'black', 'stroke-width' => 0.2 }
    );
}


#$hash_SYN{$Syn_num}->{$j}->{$keyR}->{$keyQ} = $strand;
#my $keyR = "$ref_genome" . ':' . "$chrR" . ':' . "$startR" . ':' . "$endR";
#my $keyQ = "$query_genome" . ':' . "$chrQ" . ':' . "$startQ" . ':' . "$endQ";
#绘制给定染色体区域的共线性情况
sub draw_syn_region {
	my ($SVG1, $hash_syninfo_ref, $hash_Ginfo_ref, $hash_region_ref, $syn_type, $genome_num_ref, $hash_gene_height_ref) = @_;
	my $genome_num = 0;
	my %match;
	my %inversion0;     # $inversion0{$Syn}{$R}{$Q} = signed score (正负累加)
	my %hash_match_best0;
	my %hash_inversion0;
    # 读取共线性信息文件
	foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
	{
		$genome_num++;
		my $hash_1 = $hash_syninfo_ref->{$Syn_num};
		foreach my $keyR(sort keys %{$hash_1})
		{
			my $hash_2 = $hash_syninfo_ref->{$Syn_num}->{$keyR};
			foreach my $keyQ(sort keys %{$hash_2})
			{
				my $strand = $hash_syninfo_ref->{$Syn_num}->{$keyR}->{$keyQ};
				my ($ref_genome, $chrR, $startR, $endR) = split(/:/,$keyR);
				my ($query_genome, $chrQ, $startQ, $endQ) = split(/:/,$keyQ);
				#print"test:$ref_genome\t$chrR\t$startR\t$endR:$query_genome\t$chrQ\t$startQ\t$endQ:$strand\n";
				my $lenR = abs($endR - $startR) + 1;
				if($genome_num == 1)
				{
					#将第一个基因组的染色体设置为 '+'
					$chr_orient{$genome_num}{$chrR} = '+';
				}
				$match{$Syn_num}{$chrR}{$chrQ} += $lenR;
				if($strand eq '+'){$inversion0{$Syn_num}{$chrR}{$chrQ} += $lenR;}
				elsif($strand eq '-'){$inversion0{$Syn_num}{$chrR}{$chrQ} += -$lenR;}
			}
		}
	}
	$genome_num = 0;
    # --- 对每个 Syn_num，做“一对一”的最大权匹配（贪心版） ---
    my (%best, %strand);   # 返回：$best{$Syn}{$R} = $Q；$strand{$Syn}{$R}{$Q} = '+'|'-'
    for my $Syn_num (sort { $a <=> $b } keys %match)
	{
        # 收集所有 (R,Q,score)
        my @pairs;
        for my $r (keys %{ $match{$Syn_num} }) {
            for my $q (keys %{ $match{$Syn_num}{$r} }) {
                my $s = $match{$Syn_num}{$r}{$q} // 0;
                push @pairs, [$r,$q,$s] if $s > 0;
            }
        }
        # 分数从大到小
        @pairs = sort { $b->[2] <=> $a->[2] } @pairs;

        my (%R_used, %Q_used);
        for my $p (@pairs) {
            my ($r,$q,$s) = @$p;
            next if $R_used{$r} || $Q_used{$q};     # 已占用就跳过
            $hash_match_best0{$Syn_num}{$r} = $q;
            $R_used{$r} = 1; $Q_used{$q} = 1;

            my $inv = $inversion0{$Syn_num}{$r}{$q} // 0;
            $hash_inversion0{$Syn_num}{$r}{$q} = $inv >= 0 ? '+' : '-';
        }
    }
	foreach my $Syn_num(sort{$a<=>$b} keys %hash_match_best0)
	{
		my $chr_num = 0;
		foreach my $chrR(sort keys %{$hash_match_best0{$Syn_num}})
		{
			$chr_num++;
			$hash_match_best_num{$Syn_num}->{$chrR} = $chr_num;
			my $chrQ = $hash_match_best0{$Syn_num}->{$chrR};
			my $inv = $hash_inversion0{$Syn_num}->{$chrR}->{$chrQ};
			print"Num:$Syn_num\tReference:$chrR\tQuery:$chrQ\tStrand:$inv\n";
		}
	}
    # 依次传播到 G2、G3、…
    $genome_num = 1;
    for my $Syn_num (sort { $a <=> $b } keys %hash_match_best0) {
        my $ref_num   = $genome_num;
        my $query_num = $genome_num + 1;
		my $ref_order = $aligned_order{$ref_num};
		my @query_order;
		foreach my $chrR (@$ref_order) {
			if (exists $hash_match_best0{$Syn_num}->{$chrR}) {
				my $chrQ = $hash_match_best0{$Syn_num}->{$chrR};
				my $rel  = $hash_inversion0{$Syn_num}->{$chrR}->{$chrQ};
				if($Syn_num == 1)
				{
					$chr_orient{$query_num}->{$chrQ} = $rel;
				}
				else
				{
					if($rel eq '+'){$chr_orient{$query_num}->{$chrQ} = $chr_orient{$ref_num}->{$chrR};}
					elsif($rel eq '-')
					{
						if($chr_orient{$ref_num}->{$chrR} eq '+')
						{
							$chr_orient{$query_num}->{$chrQ} = '-';
						}
						elsif($chr_orient{$ref_num}->{$chrR} eq '-')
						{
							$chr_orient{$query_num}->{$chrQ} = '+';
						}
					}
				}
			}
		}
        $genome_num++;
    }
	print"region:\n";
	foreach my $GN(sort{$a<=>$b} keys %aligned_order)
	{
		#print"$GN:\n";
		my $GN2 = $aligned_order{$GN};
		foreach my $chr (@$GN2)
		{
			my $re1 = $chr_orient{$GN}->{$chr};
			#print"$chr\t$re1\n";
		}
	}
	
	$genome_num = 0;
	my $gene_height_merge = 0;
    # 读取共线性信息文件
	foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
	{
		$genome_num++;
		#my $ref_num   = $genome_num;
		#my $query_num = $genome_num + 1;
		my $GH = $hash_gene_height_ref->{$genome_num};
		$gene_height_merge += $GH;
		my $hash_1 = $hash_syninfo_ref->{$Syn_num};
		foreach my $keyR(sort keys %{$hash_1})
		{
			my $hash_2 = $hash_syninfo_ref->{$Syn_num}->{$keyR};
			foreach my $keyQ(sort keys %{$hash_2})
			{
				my $strand = $hash_syninfo_ref->{$Syn_num}->{$keyR}->{$keyQ};
				my ($ref_num, $chrR, $R1, $R2) = split(/:/,$keyR);
				my ($query_num, $chrQ, $Q1, $Q2) = split(/:/,$keyQ);
				my $hash_regionXR = $hash_region_ref->{$ref_num};
				my ($GnameXR, $ChrXR, $StartXR, $EndXR) = split(/_:_/,$hash_regionXR);
				my $hash_regionXQ = $hash_region_ref->{$query_num};
				my ($GnameXQ, $ChrXQ, $StartXQ, $EndXQ) = split(/_:_/,$hash_regionXQ);
				my $GnameR = $hash_Ginfo_ref->{$ref_num}->{'name'};
				my $GnameQ = $hash_Ginfo_ref->{$query_num}->{'name'};
				my $chr_lenR = abs($R1 - $R2) + 1;
				my $chr_lenQ = abs($Q1 - $Q2) + 1;
				my $strandR = $chr_orient{$ref_num}->{$chrR};
				my $strandQ = $chr_orient{$query_num}->{$chrQ};
				my $region_lenR = abs($EndXR - $StartXR) + 1;
				my $region_lenQ = abs($EndXQ - $StartXQ) + 1;
				my $Rchr_width = $region_lenR / $scale;
				my $Qchr_width = $region_lenQ / $scale;
				#print"-----\n";
				#print"$GnameR:$chr_lenR:$R1\t$R2\t$strandR\n";
				#print"$GnameQ:$chr_lenQ:$Q1\t$Q2\t$strandQ\n\n";
				#print"-----\n";
				my ($startR, $endR, $startQ, $endQ);
				$R1 = ($R1-$StartXR)+1;
				$R2 = ($R2-$StartXR)+1;
				$Q1 = ($Q1-$StartXQ)+1;
				$Q2 = ($Q2-$StartXQ)+1;
				#$R1 = abs($R1-$StartXR)+1;
				#$R2 = abs($R2-$StartXR)+1;
				#$Q1 = abs($Q1-$StartXQ)+1;
				#$Q2 = abs($Q2-$StartXQ)+1;
				if($strandR eq '+')
				{
					$startR = $R1;
					$endR   = $R2;
					#print"$GnameR:$chr_lenR:$startR\t$endR\t$strandR\n";
				}
				elsif($strandR eq '-')
				{
					$startR = $chr_lenR - $R2 + 1;
					$endR   = $chr_lenR - $R1 + 1;
					#print"$GnameR:$chr_lenR:$startR\t$endR\t$strandR\n";
				}
				if($strandQ eq '+')
				{
					$startQ = $Q1;
					$endQ   = $Q2;
					#print"$GnameQ:$chr_lenQ:$startQ\t$endQ\t$strandQ\n\n";
				}
				elsif($strandQ eq '-')
				{
					$startQ = $chr_lenQ - $Q2 + 1;
					$endQ   = $chr_lenQ - $Q1 + 1;
					#print"$GnameQ:$chr_lenQ:$startQ\t$endQ\t$strandQ\n\n";
				}
				if($strandR ne $strandQ)
				{
					if($strand eq '+'){$strand = '-';}
					elsif($strand eq '-'){$strand = '+';}
				}
				if($strand eq '+'){$strand = 1;}
				elsif($strand eq '-'){$strand = 0;}
				my $chr_num = 1;
				#my $strand = (($startR < $endR) == ($startQ < $endQ)) ? 1 : 0;
				# 统一方向后算坐标
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $Chrtop + $Chrdottom + ($genome_num - 1) * ($Chrtop + $Chrdottom + $synteny_height) + $gene_height_merge;
				my $X1 = ($rect_x + $startR / $scale + ($SVG_main - $Rchr_width)/2);
				my $Y1 = ($rect_y);
				my $X2 = ($rect_x + $endR / $scale + ($SVG_main - $Rchr_width)/2);
				my $Y2 = ($rect_y);
				my $X3 = ($rect_x + $endQ / $scale + ($SVG_main - $Qchr_width)/2);
				my $Y3 = ($rect_y + $synteny_height);
				my $X4 = ($rect_x + $startQ / $scale + ($SVG_main - $Qchr_width)/2);
				my $Y4 = ($rect_y + $synteny_height);
				my $X1t = $X1;
				my $Y1t = ($rect_y - $GH / 2 - $Chrdottom);
				my $X2t = $X2;
				my $Y2t = ($rect_y - $GH / 2 - $Chrdottom);
				my $X3t = $X3;
				my $Y3t = ($rect_y + $synteny_height + $GH / 2 + $Chrtop);
				my $X4t = $X4;
				my $Y4t = ($rect_y + $synteny_height + $GH / 2 + $Chrtop);
				#my $fill_color = $strand == 1 ? "#DFDFE1" : "#E56C1A";
				my $fill_color = $strand == 1 ? "$synteny_color" : "$inversion_color";
				if($strand == 0)
				{
					$X3 = ($rect_x + $startQ / $scale + ($SVG_main - $Qchr_width)/2);
					$Y3 = ($rect_y + $synteny_height);
					$X4 = ($rect_x + $endQ / $scale + ($SVG_main - $Qchr_width)/2);
					$Y4 = ($rect_y + $synteny_height);
				}
				my $X24=$X2;
				my $Y24=($Y2+$Y4)/2;
				my $X42=$X4;
				my $Y42=$Y24;
				my $X31=$X3;
				my $Y31=($Y1+$Y3)/2;
				my $X13=$X1;
				my $Y13=($Y1+$Y3)/2;
				
				my $Y23 = ($Y2+$Y3)/2;
				my $Y14=($Y1+$Y4)/2;
				#print"$syn_type\n\n";
				if ($syn_type eq 'line')
				{
					$SVG1->polygon(
						points => #"$X1,$Y1 $X2,$Y2 $X3,$Y3 $X4,$Y4",
								$X1.','. $Y1.' '. 
								$X1t.','. $Y1t.' '.
								$X2t.','. $Y2t.' '.
								$X2.','. $Y2.' '.
								$X3.','. $Y3.' '.
								$X3t.','. $Y3t.' '.
								$X4t.','. $Y4t.' '.
								$X4.','. $Y4.'',
						style  => {
							'fill' => $fill_color,
							'fill-opacity' => 0.8,
							'stroke' => $fill_color,
							'stroke-width' => '0',
						}
					);
				}
				elsif($syn_type eq 'curve')
				{
					 my $path = "M $X1 $Y1 L $X1t $Y1t L $X2t $Y2t L $X2 $Y2 C $X2 $Y23 $X3 $Y23 $X3 $Y3 L $X3t $Y3t L $X4t $Y4t L $X4 $Y4 C $X4 $Y14 $X1 $Y14 $X1 $Y1 Z";
					 $SVG1->path(
						 d => $path,
						 style  => {
							 'fill' => $fill_color,
							 'fill-opacity' => 0.8,
							 'stroke' => $fill_color,
							 'stroke-width'=>'0',
						 }
					);
				}
			}
		}
	}
}


sub estimate_svg_text_width {
    my ($text_length) = @_;
	my $font_size = 12;  # 字体大小
	my $char_width_factor = 0.6;  # 每个字符宽度大约是字体的 60%
	my $px_to_mm = 0.264583;      # 1px ≈ 0.264583 mm
	my $width_px = $text_length * $font_size * $char_width_factor;
	my $width_mm = $width_px * $px_to_mm;
    return $width_mm;
}

sub drawing_SVG1 {
	 my ($config_ref,$global_max,$global_min,$Gname_max_num,$chrname_max_num,$chr_num_min,$genome_num) = @_;
	$SVG_x = $SVG_x_left + $Gname_max_len + $chrname_max_len + 2;
	# 在左侧添加端粒的绘制空间
	my $tel_width = 0;
	if (exists $config_ref->{'telomere_info'}) {$SVG_x += ($ChrHight / 2);$tel_width = ($ChrHight / 2);}
	## 在上侧添加图注的绘制空间
	my $legend_num = 2;
	$hash_legend{'-9999'} = "Synteny:$synteny_color";
	$hash_legend{'-9998'} = "Inversion:$inversion_color";
	# 在上侧添加端粒图注的绘制空间
	if (exists $config_ref->{'telomere_info'})
	{
		$legend_num++;
		my $color_legend = $config_ref->{'telomere_info'}->{'telomere_color'};
		#my $name_legend = 'Telomere';
		$hash_legend{'-9997'} = "Telomere:$color_legend";
	}
	# 在上侧添加着丝粒图注的绘制空间
	if (exists $config_ref->{'centromere_info'})
	{
		$legend_num++;
		#my $name_legend = 'Centromere';
		$hash_legend{'-9996'} = "Centromere:NA";
	}
	# 在上侧添加注释的图注的绘制空间
	if (exists $config_ref->{'anno_info'}) {
		my $anno_info_raw = $config_ref->{'anno_info'};
		my $anno_struct_ref = restructure_anno_info($anno_info_raw);
		my %anno_info_raw = %$anno_struct_ref;
		my @anno_numbers = sort {$a <=> $b} keys %anno_info_raw;
		foreach my $anno_number (@anno_numbers)
		{
			my $anno_entry = $anno_info_raw{$anno_number};
			my $anno_type0 = $anno_entry->{'anno_type'};
			if($anno_type0 eq 'heatmap'){$legend_num += 1;}
			else{$legend_num++;}
		}
	}
	my $line_leg = 4;
	my $legend_num_line = int(($legend_num + $line_leg - 1)/$line_leg);
	my $SVG_legend_x = $SVG_x;
	my $SVG_legend_y = $SVG_y;
	my $SVG_legend_height = 5;
	my $SVG_legend_height_merge = ($legend_num_line + 1) * $SVG_legend_height * 1.5;#+1是为了Annotation的位置
	$SVG_y += $SVG_legend_height_merge; 
	#if(){$SVG_x = $SVG_x_left + $Gname_max_len + $chrname_max_len + 2 + 5;}
	#print "\nMinimum chromosome length: $global_min\n";
    #print "Maximum chromosome length: $global_max\n";
	$scale = $global_max/$SVG_main;
	#print"\$scale:$scale\n";
	#Canvas size
	my $SVG1= SVG -> new();
	my $SVG1_canvas_w = sprintf("%.0f", $SVG_main + $SVG_x + $SVG_x_right + 15);
	my $SVG1_canvas_h = sprintf("%.0f", ($ChrHight + $Chrtop + $Chrdottom)* $chr_num_min * $genome_num + $synteny_height * ($chr_num_min) * $genome_num + $SVG_x_top + $SVG_legend_height_merge);
	$SVG1= SVG -> new(width => $SVG1_canvas_w . 'mm', height   => $SVG1_canvas_h . 'mm', viewBox => "0 0 $SVG1_canvas_w $SVG1_canvas_h");

	#绘制共线性块
	draw_syn_block($SVG1,\%hash_syninfo,\%hash_Ginfo,$syntent_type,$genome_num);
	#绘制染色体块及刻度线
	draw_chr_block($SVG1,\%hash_Ginfo,$genome_num, $tel_width);
	
	if (exists $config_ref->{'anno_info'}) {
		#绘制注释信息
		my $anno_info_raw = $config_ref->{'anno_info'};
		my %anno_info_raw = %$anno_info_raw;
		draw_anno_block($SVG1,\%anno_info_raw,\%hash_Ginfo,$genome_num);
	}
	if (exists $config_ref->{'telomere_info'})
	{
		my $telomereINFO = $config_ref->{'telomere_info'};
		my $XX1 = $config_ref->{'telomere_info'}->{'telomere_list'};
		my $XX2 = $config_ref->{'telomere_info'}->{'telomere_color'};
		my $XX3 = $config_ref->{'telomere_info'}->{'opacity'};
		#print"$XX1\t$XX2\t$XX3\n";
		
		draw_telomere_block($SVG1,$telomereINFO,\%hash_Ginfo,$genome_num);
	}
	if (exists $config_ref->{'centromere_info'})
	{
		my $centromereINFO = $config_ref->{'centromere_info'};
		draw_centromere_block($SVG1,$centromereINFO,\%hash_Ginfo,$genome_num);
	}
	
	draw_legend_block($SVG1, $SVG_legend_x, $SVG_legend_y, $SVG_legend_height, \%hash_legend);

	my $svg_file = $config_ref->{'save_info'}->{'savefig1'};
	my $svg_pdf = 1;
	if($svg_file =~ /\.pdf$/i){ $svg_file =~ s/\.pdf$/.svg/i; $svg_pdf = 2;}
	if($svg_file =~ /\.png$/i){ $svg_file =~ s/\.png$/.svg/i; $svg_pdf = 3;}
	elsif($svg_file =~ /\.svg$/i){}
	else{$svg_file .= '.svg'; $svg_pdf = 2;}
	# 输出绘图文件
	open my $svg_fh, '>', $svg_file or die "无法写入 $svg_file: $!";
	print $svg_fh $SVG1->xmlify(), "\n";
	close $svg_fh;
	print"\ndrawing_SVG1\nCanvas width: $SVG1_canvas_w mm\n";
	print"Canvas height: $SVG1_canvas_h mm\n";
	my $pdf_file = '';
	if(($svg_pdf == 2)or($svg_pdf == 3))
	{
		# 先生成目标文件名
		my $tmp_pdf = $svg_file;
		if($svg_pdf == 2){$tmp_pdf =~ s/\.svg$/.pdf/i;}
		elsif($svg_pdf == 3){$tmp_pdf =~ s/\.svg$/.png/i;}
		# 调用 CairoSVG 转换
		if (system("cairosvg $svg_file -o $tmp_pdf") == 0) {
			# 转换成功时，才更新 $pdf_file
			$pdf_file = $tmp_pdf;
		}
		else {
			#warn "转换失败：$!";
			warn "Conversion failed: $!";
		}
		return $tmp_pdf;
	}
}

sub draw_legend_block {
	my ($SVG1, $SVG_legend_X, $SVG_legend_Y, $SVG_legend_H, $hash_legend_ref) = @_;
	my $X_legend = $SVG_legend_X;
	my $Y_legend = $SVG_legend_Y;
	my $legend_width = 45;
	my $legend_width0 = 7;
	my $legend_width_gap = 2;
	$SVG1 -> text(
		 x => $X_legend,
		 y => $Y_legend,
		 style => {
			'font-family' => 'Arial', #"Courier",
			'stroke'      => 'none',
			'font-size'   => '5',
			'text-anchor' => 'start',   # 可为 start | middle | end
		}
	)->cdata("Annotations");
	$Y_legend += $SVG_legend_H * 1.5;
	my $legend_num = 0;
	foreach my $key_legend (sort{$a<=>$b} keys %{$hash_legend_ref})
	{
		$legend_num++;
		my $value_legend = $hash_legend_ref->{$key_legend};
		my @arr_lenend = split(':', $value_legend);
		if($key_legend<0)
		{
			my ($name_legend, $color_legend) = split(':', $value_legend);
			if(($name_legend eq 'Synteny') or ($name_legend eq 'Inversion'))
			{
				$SVG1 -> rect(
					 x => ($X_legend),
					 y => ($Y_legend - $SVG_legend_H),
					 width => $legend_width0,
					 height => $SVG_legend_H,
					 style=>{
						 'fill'=>"$color_legend",
						 'stroke'=>'none',
						 'stroke-width'=>'0',
					}
				);
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 + $legend_width_gap),
					 y => ($Y_legend - 1),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',   # 可为 start | middle | end
					}
				)->cdata("$name_legend");
			}
			elsif($name_legend eq 'Telomere')
			{
				my $X1 = $X_legend + $legend_width0 - $SVG_legend_H/2;
				my $Y1 = $Y_legend - $SVG_legend_H;
				my $X2 = $X_legend + $legend_width0 - $SVG_legend_H/2;
				my $Y2 = $Y_legend;
				my $X3 = $X_legend + $legend_width0;
				my $Y3 = $Y_legend - $SVG_legend_H/2;
				$SVG1->polygon(
					 points=>"$X1,$Y1 $X2,$Y2 $X3,$Y3",
					 style=>{
						 'fill'=>"$color_legend",
						 'stroke'=>'black',
						 'opacity'=>'1',
						 'stroke-width'=>'0',
					}
				);
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 + $legend_width_gap),
					 y => ($Y_legend - 1),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',   # 可为 start | middle | end
					}
				)->cdata("$name_legend");
			}
			elsif($name_legend eq 'Centromere')
			{
				my $X1 = $X_legend;
				my $Y1 = $Y_legend-$SVG_legend_H;
				my $X2 = $X_legend + 1;
				my $Y2 = $Y_legend-$SVG_legend_H;
				my $X3 = $X_legend + 1;
				my $Y3 = $Y_legend + $SVG_legend_H-$SVG_legend_H;
				my $X4 = $X_legend;
				my $Y4 = $Y_legend + $SVG_legend_H-$SVG_legend_H;
				my $X5 = $X_legend + $legend_width0;
				my $Y5 = $Y_legend-$SVG_legend_H;
				my $X6 = $X_legend + $legend_width0 - 1;
				my $Y6 = $Y_legend-$SVG_legend_H;
				my $X7 = $X_legend + $legend_width0 - 1;
				my $Y7 = $Y_legend + $SVG_legend_H-$SVG_legend_H;
				my $X8 = $X_legend + $legend_width0;
				my $Y8 = $Y_legend + $SVG_legend_H-$SVG_legend_H;
				my $r_x = $SVG_legend_H/2;
				my $r_y = $SVG_legend_H/2;
				$SVG1->path(
					d     => "M ${X1} ${Y1} L ${X2} ${Y2} A ${r_x} ${r_y} 0 0 1 ${X3} ${Y3} L ${X4} ${Y4}",
					style => {
						fill   => 'none',
						stroke => 'black',
						'stroke-width' => '0.1',
					},
				);
				$SVG1->path(
					d     => "M ${X5} ${Y5} L ${X6} ${Y6} A ${r_x} ${r_y} 0 0 0 ${X7} ${Y7} L ${X8} ${Y8}",
					style => {
						fill   => 'none',
						stroke => 'black',
						'stroke-width' => '0.1',
					},
				);
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 + $legend_width_gap),
					 y => ($Y_legend - 1),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',   # 可为 start | middle | end
					}
				)->cdata("$name_legend");
			}
		}
		else
		{
			my ($name_legend, $type_legend, $region_legend, $max_legend, $min_legend, $color_legend) = split(':', $value_legend);
			if($max_legend<=1){$max_legend = $max_legend * 100; $max_legend = "$max_legend" . '%';}
			else{$max_legend = commify($max_legend);}
			if(($min_legend > 0)and($min_legend<=1)){$min_legend = $min_legend * 100; $min_legend = "$min_legend" . '%';}
			elsif($min_legend == 0){}
			else{$min_legend = commify($min_legend);}
			if($type_legend eq 'rectangle')
			{
				$SVG1 -> rect(
					 x => ($X_legend),
					 y => ($Y_legend - $SVG_legend_H),
					 width => $legend_width0,
					 height => $SVG_legend_H,
					 style=>{
						 'fill'=>"$color_legend",
						 'stroke'=>'none',
						 'stroke-width'=>'0',
					}
				);
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 + $legend_width_gap),
					 y => ($Y_legend - 1),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',   # 可为 start | middle | end
					}
				)->cdata("$name_legend");
			}
			elsif($type_legend eq 'heatmap')
			{
				#$legend_num--;
				my $window_ref = 0.05;
				my $X1 = $X_legend;
				my $X2 = $X_legend + $legend_width*0.8;
				my $Y1 = $Y_legend - $SVG_legend_H + 1;
				my $Y2 = $Y_legend;
				for(my $Xi = $X1; $Xi <= $X2; $Xi += $window_ref)
				{
					my $gene_opacity = ($X2 - $Xi)/($X2 - $X1);
					$SVG1->line(
						x1 => $Xi, y1 => $Y1,
						x2 => $Xi, y2 => $Y2,
						style  => {
							'fill'         => 'none',       # 不填充
							'stroke'       => "$color_legend",       # 折线颜色
							'stroke-width' => "$window_ref",
							'stroke-opacity' => "$gene_opacity",
						}
					);
				}
				#my $X3 = $X1;
				#my $Y3 = $Y1 - $SVG_legend_H * 0.5;
				$SVG1->text(
					x => $X1,
					y => ($Y_legend - 1),
					style => {
						'font-family' => 'Arial',
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',
					}
				)->cdata("$name_legend");
				$SVG1->text(
					x => $X1,
					y => ($Y_legend - 2 - $SVG_legend_H/2), #($Y_legend - 1.5 + $SVG_legend_H/2),
					style => {
						'font-family' => 'Arial',
						'stroke'      => 'none',
						'font-size'   => '2',
						'text-anchor' => 'middle',
					}
				)->cdata('100%');
				$SVG1->text(
					x => $X1 + $legend_width*0.4,
					y => ($Y_legend - 2 - $SVG_legend_H/2), #($Y_legend - 1.5 + $SVG_legend_H/2),
					style => {
						'font-family' => 'Arial',
						'stroke'      => 'none',
						'font-size'   => '2',
						'text-anchor' => 'middle',
					}
				)->cdata('50%');
				$SVG1->text(
					x => $X1 + $legend_width*0.8,
					y => ($Y_legend - 2 - $SVG_legend_H/2), #($Y_legend - 1.5 + $SVG_legend_H/2),
					style => {
						'font-family' => 'Arial',
						'stroke'      => 'none',
						'font-size'   => '2',
						'text-anchor' => 'middle',
					}
				)->cdata('0');
			}
			else
			{
				my $stroke_width1 = 0.2;
				if($type_legend eq 'lineplot')
				{
					my $X1 = $X_legend + $legend_width0 - 1;
					my $Y1 = $Y_legend - $SVG_legend_H;
					my $X2 = $X_legend + $legend_width0;
					my $Y2 = $Y_legend - $SVG_legend_H;
					my $X3 = $X_legend + $legend_width0;
					my $Y3 = $Y_legend;
					my $X4 = $X_legend + $legend_width0 - 1;
					my $Y4 = $Y_legend;
					$SVG1->path(
						d     => "M ${X1} ${Y1} L ${X2} ${Y2} L ${X3} ${Y3} L ${X4} ${Y4}",
						style => {
							fill   => 'none',
							stroke => "$color_legend",
							'stroke-width' => '0.2',
						},
					);
				}
				elsif($type_legend eq 'barplot')
				{
					my $stroke_width2 = 1;
					my $X1 = $X_legend + $legend_width0 - 1 - $stroke_width2/2;
					my $Y1 = $Y_legend - $SVG_legend_H;
					my $X2 = $X_legend + $legend_width0 - $stroke_width2/2;
					my $Y2 = $Y_legend - $SVG_legend_H;
					my $X3 = $X_legend + $legend_width0 - $stroke_width2/2;
					my $Y3 = $Y_legend;
					my $X4 = $X_legend + $legend_width0 - 1 - $stroke_width2/2;
					my $Y4 = $Y_legend;
					$SVG1->path(
						d     => "M ${X1} ${Y1} L ${X2} ${Y2} L ${X3} ${Y3} L ${X4} ${Y4}",
						style => {
							fill   => 'none',
							stroke => "$color_legend",
							'stroke-width' => "$stroke_width1",
						},
					);
					$SVG1->line(
						x1 => ($X2), y1 => ($Y2 - 0.1),
						x2 => ($X3), y2 => ($Y3 + 0.1),
						style => {
							'stroke'       => "$color_legend",
							'stroke-width' => "$stroke_width2",
						}
					);
				}
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 - 2),
					 y => ($Y_legend - 1.8 - $SVG_legend_H/2),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '2',
						'text-anchor' => 'end',   # 可为 start | middle | end
					}
				)->cdata("$max_legend");
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 - 2),
					 y => ($Y_legend - 1.8 + $SVG_legend_H/2),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '2',
						'text-anchor' => 'end',   # 可为 start | middle | end
					}
				)->cdata("$min_legend");
				
				#my $name_merge = "$name_legend" . ' (' . "$region_legend" . ')';
				$SVG1 -> text(
					 x => ($X_legend + $legend_width0 + $legend_width_gap),
					 y => ($Y_legend - 1),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'start',   # 可为 start | middle | end
					}
				)->cdata("$name_legend");
			}
		}
		if($legend_num%5==0)
		{
			$Y_legend += $SVG_legend_H*1.5;
			$X_legend = $SVG_legend_X;
		}
		else{$X_legend += $legend_width;}
	}
}

#绘制着丝粒标识draw_centromere_block($SVG1,$centromereINFO,\%hash_Ginfo,$genome_num);
sub draw_centromere_block {
	my ($SVG1, $centromere_ref, $hash_Ginfo_ref, $genome_num_ref) = @_;
	my $genome_num = 0;
	my $centromere_list = $centromere_ref->{'centromere_list'};
	#print"\$centromere_list:$centromere_list\n";
	my %centromere_info;
	open my $FL_centromere, "<", $centromere_list or die "Cannot open $centromere_list: $!";
	while(<$FL_centromere>)
	{
		chomp;
		next if /^#/;  # 跳过以 # 开头的注释行
		next if /^\s*$/;  # 跳过空行
		my @tem1 = split /\t/;
		# $hash_tel_list{$tem1[0]} = $tem1[1];
		my $file_X = $tem1[1];
		my $GnumX = $tem1[0];
		open my $FL_centromereX, "<", $file_X or die "Cannot open $file_X: $!";
		while(<$FL_centromereX>)
		{
			chomp;
			next if /^#/;  # 跳过以 # 开头的注释行
			next if /^\s*$/;  # 跳过空行
			my @tem2 = split /\t/;
			my $chr0 = $tem2[0];
			my $cent_start = $tem2[1];
			my $cent_end = $tem2[2];
			$centromere_info{$GnumX}->{$chr0}->{$cent_start}->{$cent_end} = 1;
		}
		close $FL_centromereX;
	}
	close $FL_centromere;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		##### print"$Gnum:$Gname\n";
		foreach my $chr_name (sort keys %{$hashG})
		{
			$chr_num++;
			my $chr_len = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
			my $chr_width = $chr_len / $scale;
			my $hashT1 = $centromere_info{$Gnum}->{$chr_name};
			foreach my $cent_start(sort keys %{$hashT1})
			{
				my $hashT2 = $centromere_info{$Gnum}->{$chr_name}->{$cent_start};
				foreach my $cent_end(sort keys %{$hashT2})
				{
					my $rect_x = $SVG_x;
					my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
					my $r_x = ($cent_end - $cent_start + 1) / (2 * $scale);
					my $r_y = $ChrHight / 2;
					my $X1 = $rect_x + $cent_start / $scale;
					my $Y1 = $rect_y + $ChrHight;
					my $X2 = $X1;
					my $Y2 = $rect_y;
					my $X3 = $X2 + ($cent_end - $cent_start + 1) / $scale;
					my $Y3 = $Y2;
					my $X4 = $X3;
					my $Y4 = $Y1;

					$SVG1->path(
						d     => "M ${X1} ${Y1} A ${r_x} ${r_y} 0 0 0 ${X2} ${Y2} L ${X3} ${Y3} A ${r_x} ${r_y} 0 0 0 ${X4} ${Y4} Z",
						style => {
							fill   => 'white',
							stroke => 'none',
							'stroke-width' => '0',
						},
					);
					$SVG1->path(
						d     => "M ${X2} ${Y2} L ${X3} ${Y3}",
						style => {
							fill   => 'none',
							stroke => 'white',
							'stroke-width' => '0.1',
						},
					);
					$SVG1->path(
						d     => "M ${X1} ${Y1} L ${X4} ${Y4}",
						style => {
							fill   => 'none',
							stroke => 'white',
							'stroke-width' => '0.1',
						},
					);
					$SVG1->path(
						d     => "M ${X1} ${Y1} A ${r_x} ${r_y} 0 0 0 ${X2} ${Y2}",
						style => {
							fill   => 'none',
							stroke => 'black',
							'stroke-width' => '0.1',
						},
					);
					$SVG1->path(
						d     => "M ${X3} ${Y3} A ${r_x} ${r_y} 0 0 0 ${X4} ${Y4}",
						style => {
							fill   => 'none',
							stroke => 'black',
							'stroke-width' => '0.1',
						},
					);
				}

			}
		}
	}
}


#绘制端粒标识draw_telomere_block($SVG1,$telomere_info,\%hash_Ginfo,$genome_num);
sub draw_telomere_block {
	my ($SVG1, $telomere_ref, $hash_Ginfo_ref, $genome_num_ref) = @_;
	my $genome_num = 0;
	#my %hash_telomere_info = %$hash_telomere_ref;
	my $telomere_list = $telomere_ref->{'telomere_list'};
	my $telomere_color = $telomere_ref->{'telomere_color'};
	my $telomere_opacity = $telomere_ref->{'opacity'};
	#print"$telomere_list\t$telomere_color\t$telomere_opacity\n";
	#my %hash_tel_list;
	my %telomere_info;
	open my $FL_telomere, "<", $telomere_list or die "Cannot open $telomere_list: $!";
	while(<$FL_telomere>)
	{
		chomp;
		next if /^#/;  # 跳过以 # 开头的注释行
		next if /^\s*$/;  # 跳过空行
		my @tem1 = split /\t/;
		# $hash_tel_list{$tem1[0]} = $tem1[1];
		my $file_X = $tem1[1];
		my $GnumX = $tem1[0];
		open my $FL_telomereX, "<", $file_X or die "Cannot open $file_X: $!";
		while(<$FL_telomereX>)
		{
			chomp;
			next if /^#/;  # 跳过以 # 开头的注释行
			next if /^\s*$/;  # 跳过空行
			my @tem2 = split /\t/;
			my $chr0 = $tem2[0];
			my $tel_site0 = $tem2[1];
			$telomere_info{$GnumX}->{$chr0}->{$tel_site0} = 1;
		}
		close $FL_telomereX;
	}
	close $FL_telomere;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		##### print"$Gnum:$Gname\n";
		foreach my $chr_name (sort keys %{$hashG})
		{
			$chr_num++;
			my $chr_len = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
			my $chr_width = $chr_len / $scale;
			my $hashT = $telomere_info{$Gnum}->{$chr_name};
			foreach my $tel_site(sort keys %{$hashT})
			{
				##### print "$chr_name\t$chr_len\n";
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
				my $X1 = $rect_x - $ChrHight / 2;
				my $Y1 = $rect_y;
				my $X2 = $X1;
				my $Y2 = $rect_y + $ChrHight;
				my $X3 = $rect_x;
				my $Y3 = $rect_y + $ChrHight / 2;
				if($tel_site != 1)
				{
					$X1 += $chr_width + $ChrHight;
					$X2 = $X1;
					$X3 += $chr_width;
				}	
				$SVG1->polygon(
					 points=>"$X1,$Y1 $X2,$Y2  $X3,$Y3",
					 style=>{
						 'fill'=>"$telomere_color",
						 'stroke'=>'black',
						 'opacity'=>'1',
						 'stroke-width'=>'0',
					}
				);
			}
		}
	}
}

## 绘制刻度尺
sub draw_scale_axis {
	my ($SVG1, $global_max, $scale_X, $scale_Y) = @_;
	my $t_postfix="Mb";
	my $valueSpan= 5000000; 
	my $scaleXX;#最小刻度长度[eg:250_000bp]
	my $scaleYY;#标注刻度读数[eg:0Mb,5Mb]
	my $AlignmentHight = 50;
	my $SVG_x_snp = 50;
	if($global_max>=1000000000){$t_postfix="Gb";}## 1,000,000,000
	elsif($global_max>=1000000){$t_postfix="Mb";}## 1,000,000
	elsif($global_max>=1000){$t_postfix="Kb";}   ## 1,000
	elsif($global_max>=1){$t_postfix="bp";}      ## 1
	#[1Gb,~)
	if($global_max>=1000000000){$valueSpan=1000000000;$scaleYY=1;$scaleXX=$valueSpan/10;}  #1,000,000,000:1Gb;
	#[1Mb,1Gb)
	elsif($global_max>=500000000){$valueSpan=100000000;$scaleYY=100;$scaleXX=$valueSpan/10;}#500,000,000:500Mb;
	elsif($global_max>=100000000){$valueSpan=50000000;$scaleYY=50;$scaleXX=$valueSpan/10;}  #100,000,000:100Mb;
	elsif($global_max>=50000000){$valueSpan=10000000;$scaleYY=10;$scaleXX=$valueSpan/10;}   #50,000,000:50Mb;
	elsif($global_max>=10000000){$valueSpan=10000000;$scaleYY=10;$scaleXX=$valueSpan/10;}     #10,000,000:10Mb;
	elsif($global_max>=5000000){$valueSpan=1000000;$scaleYY=1;$scaleXX=$valueSpan/10;}      #5,000,000:5Mb;
	elsif($global_max>=1000000){$valueSpan=1000000;$scaleYY=1;$scaleXX=$valueSpan/10;}      #1,000,000:1Mb;
	#[1Kb,1Mb)
	elsif($global_max>=100000){$valueSpan=50000;$scaleYY=50;$scaleXX=$valueSpan/20;}        #100,000:100Kb;
	elsif($global_max>=10000){$valueSpan=5000;$scaleYY=5;$scaleXX=$valueSpan/20;}           #10,000:10Kb;
	elsif($global_max>=1000){$valueSpan=1000;$scaleYY=1;$scaleXX=$valueSpan/10;}            #1,000:1Kb;
	#[1bp,1Kb)
	elsif($global_max>=100){$valueSpan=50;$scaleYY=50;$scaleXX=$valueSpan/20;}              #100:100bp;
	elsif($global_max>=10){$valueSpan=5;$scaleYY=5;$scaleXX=1;}                             #10:10bp;
	elsif($global_max>=1){$valueSpan=1;$scaleYY=1;$scaleXX=1;}                              #1:1bp;
    my $t = 0;
	my $max_draw = $global_max;
	my $more_SIMO=int((($global_max/$valueSpan)-int($global_max/$valueSpan))*$valueSpan)+1;
	#if($more_SIMO>$scaleXX){$max_draw=(int($global_max/$valueSpan)+1)*$valueSpan;}
    #my $max_draw = int($global_max / $scaleXX) * $scaleXX;
    for (my $i = 0; $i <= $max_draw; $i += $scaleXX) {
        my $i_pXX = $i / $scale;
		#print"$i_pXX\n";
        if (($i % $valueSpan) == 0) {
            # 主刻度线 + 标签
            my $xbar = "$t$t_postfix";
            $SVG1->text(
                x => ($scale_X + $i_pXX + 1),
                y => ($scale_Y - 2),
                style => {
                    'font-family' => 'Arial',#"Courier",
                    'stroke'      => 'none',
                    'font-size'   => '4',
					#'text-anchor' => 'start',   # 可为 start | middle | end
                }
            )->cdata($xbar);
            $t += $scaleYY;
            $SVG1->line(
                x1 => ($scale_X + $i_pXX), y1 => ($scale_Y - 5),
                x2 => ($scale_X + $i_pXX), y2 => ($scale_Y),
                style => {
                    'stroke'       => 'black',
                    'stroke-width' => '0.15',
                }
            );

        } else {
            # 次刻度线
            $SVG1->line(
                x1 => ($scale_X + $i_pXX), y1 => ($scale_Y - 1),
                x2 => ($scale_X + $i_pXX), y2 => ($scale_Y),
                style => {
                    'stroke'       => 'black',
                    'stroke-width' => '0.15',
                }
            );
        }
    }

    # 最后画一条整条横轴线
    my $chrLengthXX_aa = $max_draw / $scale;
    $SVG1->line(
        x1 => ($scale_X), y1 => ($scale_Y),
        x2 => ($scale_X + $chrLengthXX_aa), y2 => ($scale_Y),
        style => {
            'stroke'       => 'black',
            'stroke-width' => '0.15',
        }
    );
}

#绘制染色体块及绘制刻度尺,\%hash_match_best
sub draw_chr_block {
	my ($SVG1, $hash_Ginfo_ref, $genome_num_ref, $tel_width) = @_;
	#my %aligned_order;  # 存储每个基因组的染色体顺序（最终与 G1 对齐）

	# 输出最终对齐顺序
	foreach my $Gnum (sort { $a <=> $b } keys %aligned_order)
	{
		my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		my $chr_tags = $hash_Ginfo_ref->{$Gnum}->{'tags'} // "height:5;opacity:0.8;color:'#39A5D6';"; #lw:1.5;color:#FF0000;opacity:1
		if (defined $chr_tags) 
		{
			if ($chr_tags =~ /height:\s*['"]?([\d.]+)['"]?/){$ChrHight = $1;}
			if ($chr_tags =~ /opacity:\s*['"]?([\d.]+)['"]?/){$Chropacity = $1;}
			if ($chr_tags =~ /color:\s*['"]?([^'";]+)['"]?/){$Chrcolor = $1;}
		}
		my @arr_chr = @{$aligned_order{$Gnum}};
		if(0)
		{
			foreach my $GN(sort{$a<=>$b} keys %aligned_order)
			{
				my $GnameN = $hash_Ginfo_ref->{$GN}->{'name'};
				#print"$GN $GnameN:\n";
				my $GN2 = $aligned_order{$GN};
				my $outputchr_ch;
				my @arr_chr_chain;
				foreach my $chr (@$GN2)
				{
					my $re1 = $chr_orient{$GN}->{$chr};
					#print"$chr\t$re1\n";
					$outputchr_ch = "$chr" . '[' . "$re1" . ']';
					push(@arr_chr_chain,$outputchr_ch);
				}
				my $output_merge = join(",",@arr_chr_chain);
				#print "$GN $GnameN: @arr_chr_chain\n";
				print "$GN $GnameN: $output_merge\n";
				#print "$Gnum $Gname: @arr_chr\n";
			}
		}
		my $chr_number = 0;
		foreach my $chr_name(@arr_chr)
		{
			$chr_number++;
			my $chr_len = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
			##### print "$chr_name\t$chr_len\n";
			my $rect_x = $SVG_x;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_number - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($Gnum - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
			# 绘制reference长度的刻度线
			if($Gnum == 1){draw_scale_axis($SVG1, $chr_len, $rect_x, $rect_y - 2 - $Chrtop);}
			##### chromosome region
			my $chr_width = $chr_len / $scale;
			my $chr_r = $ChrHight/2;
			$chr_r = $chr_r;
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'#FFFFFF',
					 'stroke'=>'#FFFFFF',
					 'rx'=>"$chr_r",
					 'ry'=>"$chr_r",
					 'stroke-width'=>'0.1',
				}
			);
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>"$Chrcolor",
					 'fill-opacity'   => "$Chropacity",
					 'stroke'=>'black',
					 'rx'=>"$chr_r",
					 'ry'=>"$chr_r",
					 'stroke-width'=>'0.1',
				}
			);
			my $dot = "&#183;";  # HTML实体形式（中点字符）
			my $NAME_Gchr = "$Gname" . $dot . "$hash_chrGAI{$Gnum}->{$chr_name}";
			my $X1 = ($rect_x - $tel_width - 2);
			$SVG1 -> text(
				 x => $X1,
				 y => ($rect_y + $ChrHight*3/4),
                 style => {
                    'font-family' => 'Arial', #"Courier",
                    'stroke'      => 'none',
                    'font-size'   => '4',
					'text-anchor' => 'end',   # 可为 start | middle | end
                }
			)->cdata("$NAME_Gchr");
		}
	}
}


sub find_best_synteny_matches {
    my ($hash_Ginfo_ref, $hash_syninfo_ref) = @_;
    my %match;          # $match{$Syn}{$R}{$Q} = score
    my %inversion0;     # $inversion0{$Syn}{$R}{$Q} = signed score (正负累加)
    # --- 读取共线性文件，直接累加打分（无需预初始化） ---
    for my $Syn_num (sort { $a <=> $b } keys %{$hash_syninfo_ref})
	{
        my $aln = $hash_syninfo_ref->{$Syn_num}{align} or die "No align file for Syn $Syn_num\n";
        open my $FL_align, "<", $aln or die "Cannot open $aln: $!";
        while (<$FL_align>)
		{
            chomp;
            next if /^#/ || /^\s*$/;
            my @t = split /\t/;
            my ($rChr,$r1,$r2,$qChr,$q1,$q2,$strand) = @t[0,1,2,3,4,5,6];
            my $lenR = abs($r2 - $r1) + 1;
            $match{$Syn_num}{$rChr}{$qChr} += $lenR;
            #my $same_dir = ($r1 <= $r2 && $q1 <= $q2) || ($r1 >  $r2 && $q1 >  $q2);
            #$inversion0{$Syn_num}{$rChr}{$qChr} += $same_dir ? $lenR : -$lenR;
			if($strand eq '+'){$inversion0{$Syn_num}{$rChr}{$qChr} += $lenR;}
			elsif($strand eq '-'){$inversion0{$Syn_num}{$rChr}{$qChr} += -$lenR;}
        }
        close $FL_align;
    }

    # --- 对每个 Syn_num，做“一对一”的最大权匹配（贪心版） ---
    my (%best, %strand);   # 返回：$best{$Syn}{$R} = $Q；$strand{$Syn}{$R}{$Q} = '+'|'-'
    for my $Syn_num (sort { $a <=> $b } keys %match)
	{
        # 收集所有 (R,Q,score)
        my @pairs;
        for my $r (keys %{ $match{$Syn_num} }) {
            for my $q (keys %{ $match{$Syn_num}{$r} }) {
                my $s = $match{$Syn_num}{$r}{$q} // 0;
                push @pairs, [$r,$q,$s] if $s > 0;
            }
        }
        # 分数从大到小
        @pairs = sort { $b->[2] <=> $a->[2] } @pairs;

        my (%R_used, %Q_used);
        for my $p (@pairs) {
            my ($r,$q,$s) = @$p;
            next if $R_used{$r} || $Q_used{$q};     # 已占用就跳过
            $hash_match_best{$Syn_num}{$r} = $q;
            $R_used{$r} = 1; $Q_used{$q} = 1;

            my $inv = $inversion0{$Syn_num}{$r}{$q} // 0;
            $hash_inversion{$Syn_num}{$r}{$q} = $inv >= 0 ? '+' : '-';
        }
    }
	foreach my $Syn_num(sort{$a<=>$b} keys %hash_match_best)
	{
		my $chr_num = 0;
		my $aln = $hash_syninfo_ref->{$Syn_num}{align};
		#print"$Syn_num:$aln\n";
		foreach my $chrR(sort keys %{$hash_match_best{$Syn_num}})
		{
			$chr_num++;
			$hash_match_best_num{$Syn_num}->{$chrR} = $chr_num;
			my $chrQ = $hash_match_best{$Syn_num}->{$chrR};
			my $inv = $hash_inversion{$Syn_num}->{$chrR}->{$chrQ};
			#print"Num:$chr_num\tReference:$chrR\tQuery:$chrQ\tStrand:$inv\n";
		}
	}
	my $genome_num = 1;
	# Step 1: G1 染色体顺序直接取
	$aligned_order{$genome_num} = \@arr_ref_chrname;

	# Step 2+: 依次对齐 G2, G3, ...
	foreach my $Syn_num (sort { $a <=> $b } keys %hash_match_best) {
		my $ref_genome   = $genome_num;
		my $query_genome = $genome_num + 1;

		my $ref_order = $aligned_order{$ref_genome};
		my @query_order;

		foreach my $chrR (@$ref_order) {
			if (exists $hash_match_best{$Syn_num}->{$chrR}) {
				my $chrQ = $hash_match_best{$Syn_num}->{$chrR};
				push @query_order, $chrQ;
			}
		}
		$aligned_order{$query_genome} = \@query_order;
		$genome_num++;
	}
	
    # G1 全部设为 '+'
    $chr_orient{1}{$_} = '+' for keys %{$hash_Ginfo_ref->{1}{chr}};

    # 依次传播到 G2、G3、…
    $genome_num = 1;
    for my $Syn_num (sort { $a <=> $b } keys %hash_match_best) {
        my $ref_genome   = $genome_num;
        my $query_genome = $genome_num + 1;
		my $ref_order = $aligned_order{$ref_genome};
		my @query_order;
		foreach my $chrR (@$ref_order) {
			if (exists $hash_match_best{$Syn_num}->{$chrR}) {
				my $chrQ = $hash_match_best{$Syn_num}->{$chrR};
				my $rel  = $hash_inversion{$Syn_num}->{$chrR}->{$chrQ};
				if($Syn_num == 1)
				{
					$chr_orient{$query_genome}->{$chrQ} = $rel;
				}
				else
				{
					if($rel eq '+'){$chr_orient{$query_genome}->{$chrQ} = $chr_orient{$ref_genome}->{$chrR};}
					elsif($rel eq '-')
					{
						if($chr_orient{$ref_genome}->{$chrR} eq '+')
						{
							$chr_orient{$query_genome}->{$chrQ} = '-';
						}
						elsif($chr_orient{$ref_genome}->{$chrR} eq '-')
						{
							$chr_orient{$query_genome}->{$chrQ} = '+';
						}
					}
				}
			}
		}
        $genome_num++;
    }
	print"\nSort match:\n";
	foreach my $GN(sort{$a<=>$b} keys %aligned_order)
	{
		my $GnameN = $hash_Ginfo_ref->{$GN}->{'name'};
		#print"$GN $GnameN:\n";
		my $GN2 = $aligned_order{$GN};
		my $outputchr_ch;
		my @arr_chr_chain;
		foreach my $chr (@$GN2)
		{
			my $re1 = $chr_orient{$GN}->{$chr};
			#print"$chr\t$re1\n";
			$outputchr_ch = "$chr" . '[' . "$re1" . ']';
			push(@arr_chr_chain,$outputchr_ch);
		}
		my $output_merge = join(",",@arr_chr_chain);
		#print "$GN $GnameN: @arr_chr_chain\n";
		print "$GN $GnameN: $output_merge\n";
		#print "$Gnum $Gname: @arr_chr\n";
	}
	print"\n";
}

sub draw_syn_block {
	my ($SVG1, $hash_syninfo_ref, $hash_Ginfo_ref, $syn_type,$genome_num_ref) = @_;
	my $genome_num = 0;
    # 读取共线性信息文件
	foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
	{
		$genome_num++;
		my $ref_genome   = $genome_num;
		my $query_genome = $genome_num + 1;
		my @arr_chrR = @{$aligned_order{$ref_genome}};
		my @arr_chrQ = @{$aligned_order{$query_genome}};
		# 建立 chr => index 的映射，方便快速查找下标
		my %posR = map { $arr_chrR[$_] => $_ } 0 .. $#arr_chrR;
		my %posQ = map { $arr_chrQ[$_] => $_ } 0 .. $#arr_chrQ;
		my $Syn_align = $hash_syninfo_ref->{$Syn_num}->{'align'};
		open my $FL_align, "<", $Syn_align or die "Cannot open $Syn_align: $!";
		while(<$FL_align>)
		{
			chomp;
			next if /^#/;  # 跳过以 # 开头的注释行
			next if /^\s*$/;  # 跳过空行
			my @tem = split /\t/;
			my $chrR = $tem[0];
			my $chrQ = $tem[3];
			my $chr_lenR = $hash_Ginfo_ref->{$ref_genome}->{'chr'}->{$chrR};
			my $chr_lenQ = $hash_Ginfo_ref->{$query_genome}->{'chr'}->{$chrQ};
			my $GnameR = $hash_Ginfo_ref->{$ref_genome}->{'name'};
			my $GnameQ = $hash_Ginfo_ref->{$query_genome}->{'name'};
			my ($startR, $endR, $startQ, $endQ);

			# 先检查 chr 是否存在于各自数组中
			next unless exists $posR{$chrR};
			next unless exists $posQ{$chrQ};
			# 索引位置必须相同
			if ($posR{$chrR} == $posQ{$chrQ}) {
				my $strandR = $chr_orient{$ref_genome}->{$chrR};
				my $strandQ = $chr_orient{$query_genome}->{$chrQ};
				if($strandR eq '+')
				{
					$startR = $tem[1];
					$endR   = $tem[2];
					#print"$GnameR:$chr_lenR:$tem[1]\t$tem[2]\n";
					#print"$startR:$endR:$strandR\n";
				}
				elsif($strandR eq '-')
				{
					$startR = $chr_lenR - $tem[2] + 1;
					$endR   = $chr_lenR - $tem[1] + 1;
					#print"$GnameR:$chr_lenR:$tem[1]\t$tem[2]\n";
					#print"$startR:$endR:$strandR\n";
				}
				if($strandQ eq '+')
				{
					$startQ = $tem[4];
					$endQ   = $tem[5];
					#print"$GnameQ:$chr_lenQ:$tem[4]\t$tem[5]\n";
					#print"$startQ\t$endQ:$strandQ\n";
				}
				elsif($strandQ eq '-')
				{
					$startQ = $chr_lenQ - $tem[5] + 1;
					$endQ   = $chr_lenQ - $tem[4] + 1;
					#print"$GnameQ:$chr_lenQ:$tem[4]\t$tem[5]\n";
					#print"$startQ\t$endQ:$strandQ\n";
				}
				my $strand = $tem[6];
				if($strandR ne $strandQ)
				{
					if($strand eq '+'){$strand = '-';}
					elsif($strand eq '-'){$strand = '+';}
				}
				if($strand eq '+'){$strand = 1;}
				elsif($strand eq '-'){$strand = 0;}
				#### 这里写后续代码逻辑
				#print "PASS: $chrR ↔ $chrQ (index=$posR{$chrR})\n";
				my $chr_num = $posR{$chrR} + 1;
				#my $strand = (($startR < $endR) == ($startQ < $endQ)) ? 1 : 0;
				# 统一方向后算坐标
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $Chrtop + $ChrHight + $Chrdottom + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
				my $X1 = sprintf("%.2f", $rect_x + $startR / $scale);
				my $Y1 = sprintf("%.2f", $rect_y);
				my $X2 = sprintf("%.2f", $rect_x + $endR / $scale);
				my $Y2 = sprintf("%.2f", $rect_y);
				my $X3 = sprintf("%.2f", $rect_x + $endQ / $scale);
				my $Y3 = sprintf("%.2f", $rect_y + $synteny_height);
				my $X4 = sprintf("%.2f", $rect_x + $startQ / $scale);
				my $Y4 = sprintf("%.2f", $rect_y + $synteny_height);
				my $X1t = sprintf("%.2f", $rect_x + $startR / $scale);
				my $Y1t = sprintf("%.2f", $rect_y - $ChrHight / 2 - $Chrdottom);
				my $X2t = sprintf("%.2f", $rect_x + $endR / $scale);
				my $Y2t = sprintf("%.2f", $rect_y - $ChrHight / 2 - $Chrdottom);
				my $X3t = sprintf("%.2f", $rect_x + $endQ / $scale);
				my $Y3t = sprintf("%.2f", $rect_y + $synteny_height + $ChrHight / 2 + $Chrtop);
				my $X4t = sprintf("%.2f", $rect_x + $startQ / $scale);
				my $Y4t = sprintf("%.2f", $rect_y + $synteny_height + $ChrHight / 2 + $Chrtop);
				#my $fill_color = $strand == 1 ? "#DFDFE1" : "#E56C1A";
				my $fill_color = $strand == 1 ? "$synteny_color" : "$inversion_color";
				if($strand == 0)
				{
					$X3 = sprintf("%.2f", $rect_x + $startQ / $scale);
					$Y3 = sprintf("%.2f", $rect_y + $synteny_height);
					$X4 = sprintf("%.2f", $rect_x + $endQ / $scale);
					$Y4 = sprintf("%.2f", $rect_y + $synteny_height);
					$X3t = sprintf("%.2f", $rect_x + $startQ / $scale);
					$Y3t = sprintf("%.2f", $rect_y + $synteny_height + $ChrHight / 2 + $Chrtop);
					$X4t = sprintf("%.2f", $rect_x + $endQ / $scale);
					$Y4t = sprintf("%.2f", $rect_y + $synteny_height + $ChrHight / 2 + $Chrtop);
				}
				my $Y23 = sprintf("%.2f", ($Y2+$Y3)/2);
				my $Y14 = sprintf("%.2f", ($Y1+$Y4)/2);
				if ($syn_type eq 'line')
				{
					$SVG1->polygon(
						points => #"$X1,$Y1 $X2,$Y2 $X3,$Y3 $X4,$Y4",
								$X1.','. $Y1.' '. 
								$X1t.','. $Y1t.' '.
								$X2t.','. $Y2t.' '.
								$X2.','. $Y2.' '.
								$X3.','. $Y3.' '.
								$X3t.','. $Y3t.' '.
								$X4t.','. $Y4t.' '.
								$X4.','. $Y4.'',
						style  => {
							'fill' => $fill_color,
							'fill-opacity' => 0.8,
							'stroke' => $fill_color,
							'stroke-width' => '0',
						}
					);
				}
				elsif($syn_type eq 'curve')
				{
					 my $path = "M $X1 $Y1 L $X1t $Y1t L $X2t $Y2t L $X2 $Y2 C $X2 $Y23 $X3 $Y23 $X3 $Y3 L $X3t $Y3t L $X4t $Y4t L $X4 $Y4 C $X4 $Y14 $X1 $Y14 $X1 $Y1 Z";
					 $SVG1->path(
						 d => $path,
						 style  => {
							 'fill' => $fill_color,
							 'fill-opacity' => 0.8,
							 'stroke' => $fill_color,
							 'stroke-width'=>'0',
						 }
					);
				}
			}
		}
		close $FL_align;
	}
}

#绘制注释信息块 draw_anno_block($SVG1,\%anno_info_raw);
sub draw_anno_block {
	my ($SVG1, $hash_anno_ref, $hash_Ginfo_ref, $genome_num_ref) = @_;
	my %dispatch = (
		lineplot  => \&draw_lineplot,
		rectangle => \&draw_rectangle,
		heatmap   => \&draw_heatmap,
		barplot   => \&draw_barplot,
	);
	my $anno_struct_ref = restructure_anno_info($hash_anno_ref);
	my %anno_info = %$anno_struct_ref;
	my @anno_numbers = sort {$a <=> $b} keys %anno_info;
	my @anno_position;          # 用于存储所有 position
	my %hash_annotype; 
	my %seen1;                  # 辅助哈希
	foreach my $anno_number (@anno_numbers) {
		my $anno_entry = $anno_info{$anno_number};
		my $anno_position0 = $anno_entry->{'anno_position'};
		my $anno_type0 = $anno_entry->{'anno_type'};
		$hash_annotype{$anno_type0} = 1;
		# 去重存储
		if (!$seen1{$anno_position0}++) {
			push(@anno_position, $anno_position0);
		}
	}
	my $anno0 = 0;
	# 绘制注释信息块
	foreach my $anno_number (@anno_numbers) {
		$anno0++;
		my $anno_entry = $anno_info{$anno_number};
		my $anno_name0 = $anno_entry->{'anno_name'};
		my $anno_type0 = $anno_entry->{'anno_type'};
		my $anno_path0 = $anno_entry->{'anno_list'};
		my $anno_color0 = $anno_entry->{'anno_color'};
		my $anno_position0 = $anno_entry->{'anno_position'};
		my $anno_height0 = $anno_entry->{'anno_height'};
		my $min_max_value0 = $anno_entry->{'min_max_value'};
		my ($min_value0, $max_value0);
		#print"$anno_number:$min_max_value0\n";
		if(($min_max_value0 ne 'auto')and($min_max_value0 ne 'normal')and($min_max_value0 ne 'ratio'))
		{
			($min_value0, $max_value0) = parse_min_max("$min_max_value0");
			#($min_value0, $max_value0) = $min_max_value0 =~ /\(([^:]+):([^)]+)\)/;
		}
		my $anno_window0 = $anno_entry->{'anno_window'};
		my $anno_opacity0 = $anno_entry->{'opacity'};
		my $anno_file_type0 = $anno_entry->{'file_type'};
		my $anno_filter_type0 = $anno_entry->{'filter_type'};
		# 绘制注释外边框
		if($anno0 == 1){draw_anno_frame($anno_entry, \%hash_annotype, \@anno_position, $hash_Ginfo_ref, $genome_num_ref, $SVG1);}
		my %hash_ANNO;
		my $annovalue_min;
		my $annovalue_max;
		my %hash_annoX;
		my %hash_annoY;
		my $win_factor = 1;
		my $anno_bin = $anno_window0;
		#print "  $anno_number. " . $anno_entry->{'anno_name'} . " (Type: " . $anno_entry->{'anno_type'} . "): " . "$anno_entry->{'anno_list'}" . "\n";
		open my $FL_annotation, "<", $anno_path0 or die "Cannot open $anno_path0: $!";
		while(<$FL_annotation>)
		{
			chomp;
			next if /^#/;  # 跳过以 # 开头的注释行
			next if /^\s*$/;  # 跳过空行
			my @tem1 = split /\t/;
			$hash_ANNO{$tem1[0]} = $tem1[1];
			my $file_anno = $tem1[1];
			my $GnumX = $tem1[0];
			if($anno_file_type0 eq 'bed')
			{
				my $i = 0;
				my $Actual_win_size;
				open my $FL_annotationX, "<", $file_anno or die "Cannot open $file_anno: $!";
				while(<$FL_annotationX>)
				{
					chomp;
					next if /^#/;  # 跳过以 # 开头的注释行
					next if /^\s*$/;  # 跳过空行
					my @tem2 = split /\t/;
					$i++;
					my $chr0 = $tem2[0];
					my $start0 = $tem2[1];
					my $end0 = $tem2[2];
					my $value0 = $tem2[3];
					if($i==1){ $Actual_win_size = abs($end0 - $start0) + 1; }
					$value0 = lc($value0) if defined $value0;  # 将其转为小写
					my $filter = $anno_filter_type0;
					if($anno_filter_type0 ne 'none')
					{
						$filter = $tem2[4];
					}
					if($filter eq $anno_filter_type0)
					{
						if(($value0 eq '.')or($value0 eq 'none')or($value0 eq '-'))
						{
							$value0 = abs($end0 - $start0) + 1;
						}
						$hash_annoY{$GnumX}->{$chr0}->{$start0}->{$end0}=$value0;
						# 更新最大值
						if (!defined $annovalue_max || $value0 > $annovalue_max) {
							$annovalue_max = $value0;
						}

						# 更新最小值
						if (!defined $annovalue_min || $value0 < $annovalue_min) {
							$annovalue_min = $value0;
						}
					}
				}
				close $FL_annotationX;
				if ($anno_window0 ne 'none') { #$anno_window0 = $Actual_win_size;}
					if($anno_window0 < $Actual_win_size)
					{
						die "Error: Set window size ($anno_window0) is smaller than actual window size ($Actual_win_size).\n";
					}
					elsif($anno_window0 == $Actual_win_size)
					{
						%hash_annoX = %hash_annoY;
					}
					elsif ($anno_window0 > $Actual_win_size)
					{
						# 检查是否为整数倍
						if ($anno_window0 % $Actual_win_size != 0) {
							warn "Error: type: $anno_name0 - Window size ($anno_window0) is not an integer multiple of actual window size ($Actual_win_size). Skipping...\n";
							next;
						}
						$win_factor = int($anno_window0 / $Actual_win_size);
						if($win_factor != 1){($annovalue_min, $annovalue_max, %hash_annoX) = bed_to_newWindows($GnumX, $hash_Ginfo_ref, $anno_window0, \%hash_annoY);}
						else{%hash_annoX = %hash_annoY;}
					}
				}
				elsif($anno_window0 eq 'none'){%hash_annoX = %hash_annoY;$anno_bin = $Actual_win_size;}
			}
			elsif(($anno_file_type0 eq 'gff3')or($anno_file_type0 eq 'gff'))
			{
				($annovalue_min, $annovalue_max) = gff3_TO_bed($GnumX, $hash_Ginfo_ref, $file_anno, \%hash_annoX, $anno_window0, $anno_filter_type0);
			}
			elsif(($anno_file_type0 eq 'gtf'))
			{
				warn "Error: GTF file format is not supported in this script. Please use GFF3 or BED format.\n";
				die  "Terminating program due to unsupported file type: gtf\n";
			}
		}
		close $FL_annotation;
		$anno_bin = num2char($anno_bin);
		##### annotation region
		my $ANNO_file = $hash_ANNO{$anno_number};
		if (exists $dispatch{$anno_type0}) {
			# 调用对应子程序，传递当前记录[draw_lineplot, draw_rectangle, draw_heatmap, draw_barplot]
			$dispatch{$anno_type0}->($anno_entry, $hash_Ginfo_ref, $genome_num_ref, \%hash_annoX, $annovalue_max, $annovalue_min, $SVG1);
			if(($min_max_value0 ne 'auto')and($min_max_value0 ne 'normal')and($min_max_value0 ne 'ratio')) #{($min_value0, $max_value0) = $min_max_value0 =~ /\(([^:]+):([^)]+)\)/;}
			{
				$hash_legend{$anno_number} = "$anno_name0:$anno_type0:$anno_bin:$max_value0:$min_value0:$anno_color0";
				#print"$anno_number:$anno_name0:$anno_type0:$anno_bin:$max_value0:$min_value0:$anno_color0\n";
			}
			else
			{
				$hash_legend{$anno_number} = "$anno_name0:$anno_type0:$anno_bin:$annovalue_max:$annovalue_min:$anno_color0";
				#print"$anno_number:$anno_name0:$anno_type0:$anno_bin:$annovalue_max:$annovalue_min:$anno_color0\n";
			}
		}
		else {
			warn "Warning: Unknown annotation type '$anno_type0'\n";
		}
	}
}

# ==== 不同类型的绘制函数 ====
sub draw_lineplot {
    my ($entry, $hash_Ginfo_ref, $genome_num_ref, $hash_annoX_ref, $max_anno, $min_anno, $SVG1) = @_;
	my %hash_annoX1 = %$hash_annoX_ref;
    print "Draw line chart for $entry->{anno_name}\n";
	print "min:$min_anno\nmax:$max_anno\n";
	my $anno_color0 = $entry->{'anno_color'};
	my $anno_position0 = $entry->{'anno_position'};
	my $anno_height0 = $entry->{'anno_height'} - 0.1;
	my $min_max_value0 = $entry->{'min_max_value'};
	my $anno_opacity0 = $entry->{'opacity'} // 1;
    # 处理百分比
    $anno_opacity0 =~ s/%$//;
    $anno_opacity0 = 0.0 + $anno_opacity0 if $anno_opacity0;
   # 如果 min_max_value0 是区间 "(min:max)"
    my ($min_value0, $max_value0);
    if($min_max_value0 !~ /^(auto|normal|ratio)$/){
        ($min_value0, $max_value0) = parse_min_max("$min_max_value0");
        $min_value0 += 0; $max_value0 += 0;
    }
	my $genome_num = 0;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		#my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		##### print"$Gnum:$Gname\n";
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		foreach my $chr_name (sort keys %{$hashG})
		{
			$chr_num++;
			my @anno_line;
			my $rect_x = $SVG_x;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
			if($anno_position0 eq 'top'){$rect_y -= ($anno_height0 + 0.1);}
			elsif($anno_position0 eq 'bottom'){$rect_y += ($ChrHight + 0.1);}
			##### annotation region
			my $CHR_anno = $hash_annoX1{$Gnum}->{$chr_name} // next;
			my %hash_win_value;
			my @arr_polyline;
			foreach my $start_anno (sort { $a <=> $b } keys %{$CHR_anno}) {
				foreach my $end_anno (sort { $a <=> $b } keys %{ $CHR_anno->{$start_anno} }) {
					my $anno_Win_size = abs($end_anno - $start_anno) + 1;
					my $value = $CHR_anno->{$start_anno}->{$end_anno};
					my $height_ratio;
					#if($value > 1){$min_max_value0 = 'normal';}
					#elsif($value < 1){$min_max_value0 = 'ratio';}

					if($min_max_value0 eq 'normal')
					{
						$height_ratio = $value / $anno_Win_size;
					}
					elsif($min_max_value0 eq 'ratio')
					{
						$height_ratio = $value;
					}
					elsif($min_max_value0 eq 'auto')
					{
						$height_ratio = ($value - $min_anno)/($max_anno - $min_anno);
					}
					else
					{
                        if($value > 1 ){$height_ratio = $value / $anno_Win_size;}
                        elsif($value < 1){$height_ratio = $value;}
                        $height_ratio = $height_ratio > $max_value0 ? $max_value0 : $height_ratio;
                        $height_ratio = $height_ratio < $min_value0 ? $min_value0 : $height_ratio;
						$height_ratio = ($height_ratio - $min_value0)/($max_value0 - $min_value0);
                        #print"\$max_value0:$max_value0;\$min_value0:$min_value0;\$value:$value;\$anno_Win_size:$anno_Win_size;\$height_ratio:$height_ratio\n";
					}
					###print "Chr: $chr_name\tStart: $start_anno\tEnd: $end_anno\tValue: $value\n";
					my $X1 = $rect_x + (($start_anno + $end_anno)/2) / $scale;
					my $Y1 = $rect_y;
					if($anno_position0 eq 'top')
					{
						$Y1 += ($anno_height0 * (1 - $height_ratio));
					}
					elsif($anno_position0 eq 'bottom')
					{
						$Y1 += ($height_ratio * $anno_height0);
					}
					elsif($anno_position0 eq 'middle')
					{
						$Y1 += ($ChrHight - $height_ratio * $anno_height0 - 0.05);
					}
					my $xy_merge = "$X1" . ',' . "$Y1";
					push(@arr_polyline, $xy_merge);
				}
			}
			my $arr_line = join(' ', @arr_polyline);
			$SVG1->polyline(
				 points=>"$arr_line",
				 style=>{
					 'fill' => 'none',
					 'stroke' => "$anno_color0",  
					 'stroke-opacity' => "$anno_opacity0",
					 'stroke-width' => 0.1,
					 'stroke-linejoin' => 'round',   # 拐角圆角
					 'stroke-linecap' => 'round',   # 端点圆角（可选）
				}
			);
		}
	}
}
sub draw_barplot {
    my ($entry, $hash_Ginfo_ref, $genome_num_ref, $hash_annoX_ref, $max_anno, $min_anno, $SVG1) = @_;
	my %hash_annoX1 = %$hash_annoX_ref;
    print "Draw bar chart for $entry->{anno_name}\n";
	print "min:$min_anno\nmax:$max_anno\n";
	my $anno_color0 = $entry->{'anno_color'};
	my $anno_position0 = $entry->{'anno_position'};
	my $anno_height0 = $entry->{'anno_height'} - 0.1;
	my $min_max_value0 = $entry->{'min_max_value'};
	my $anno_opacity0 = $entry->{'opacity'} // 1;
    # 处理百分比
    $anno_opacity0 =~ s/%$//;
    $anno_opacity0 = 0.0 + $anno_opacity0 if $anno_opacity0;
   # 如果 min_max_value0 是区间 "(min:max)"
    my ($min_value0, $max_value0);
    if($min_max_value0 !~ /^(auto|normal|ratio)$/){
        ($min_value0, $max_value0) = parse_min_max("$min_max_value0");
        $min_value0 += 0; $max_value0 += 0;
    }
	my $genome_num = 0;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		#my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		##### print"$Gnum:$Gname\n";
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		foreach my $chr_name (sort keys %{$hashG})
		{
			$chr_num++;
			my @anno_line;
			my @anno_piont;
			my @ANNO_window;
			my $rect_x = $SVG_x;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
			if($anno_position0 eq 'top'){$rect_y -= ($anno_height0 + 0.05);}
			elsif($anno_position0 eq 'bottom'){$rect_y += ($ChrHight + 0.05);}
			##### annotation region
			my $CHR_anno = $hash_annoX1{$Gnum}->{$chr_name} // next;
			foreach my $start_anno (sort { $a <=> $b } keys %{$CHR_anno}) {
				foreach my $end_anno (sort { $a <=> $b } keys %{ $CHR_anno->{$start_anno} }) {
					my $anno_Win_size = abs($end_anno - $start_anno) + 1;
					my $value = $CHR_anno->{$start_anno}->{$end_anno};
					my $height_ratio;
					#if(($value > 1)){$min_max_value0 = 'normal';}
					#elsif($value < 1){$min_max_value0 = 'ratio';}
					if($min_max_value0 eq 'normal')
					{
						$height_ratio = $value / $anno_Win_size;
					}
					elsif($min_max_value0 eq 'ratio')
					{
						$height_ratio = $value;
					}
					elsif($min_max_value0 eq 'auto')
					{
						$height_ratio = ($value - $min_anno)/($max_anno - $min_anno);
					}
					else
					{
                        if($value > 1 ){$height_ratio = $value / $anno_Win_size;}
                        elsif($value < 1){$height_ratio = $value;}
                        $height_ratio = $height_ratio > $max_value0 ? $max_value0 : $height_ratio;
                        $height_ratio = $height_ratio < $min_value0 ? $min_value0 : $height_ratio;
						$height_ratio = ($height_ratio - $min_value0)/($max_value0 - $min_value0);
                        #print"\$max_value0:$max_value0;\$min_value0:$min_value0;\$value:$value;\$anno_Win_size:$anno_Win_size;\$height_ratio:$height_ratio\n";
					}
					my $X1 = ($rect_x + (($start_anno + $end_anno)/2) / $scale);
					my $Y1 = $rect_y;
					my $X2 = $X1;
					my $Y2 = $rect_y;
					if($anno_position0 eq 'top')
					{
						$Y1 += ($anno_height0 - $height_ratio * $anno_height0);
						$Y2 += ($anno_height0);
					}
					elsif($anno_position0 eq 'bottom')
					{
						$Y1 += ($height_ratio * $anno_height0);
					}
					elsif($anno_position0 eq 'middle')
					{
						$Y1 += ($ChrHight - $height_ratio * $anno_height0 + 0.05);
						$Y2 += ($ChrHight - 0.05);
					}
					push @anno_line, [$X1, $Y1];
					push @anno_piont, [$X2, $Y2];
					push (@ANNO_window, $anno_Win_size);
				}
			}
			for (my $i = 0; $i <= $#anno_line; $i++) {
				my ($x1, $y1) = @{$anno_line[$i]};
				my ($x2, $y2) = @{$anno_piont[$i]};
				my $window_ref = $ANNO_window[$i] / $scale;
				# 这里你可以绘制一条线段
				$SVG1->line(
					x1 => $x1, y1 => $y1,
					x2 => $x2, y2 => $y2,
					style  => {
						'fill'         => 'none',       # 不填充
						'stroke'       => "$anno_color0",       # 折线颜色
						'stroke-width' => "$window_ref",
						'stroke-opacity'   => "$anno_opacity0",
					}
				);
			}
		}
	}
}

sub draw_rectangle {
    my ($entry, $hash_Ginfo_ref, $genome_num_ref, $hash_annoX_ref, $max_anno, $min_anno, $SVG1) = @_;
	my %hash_annoX1 = %$hash_annoX_ref;
    print "Draw rectangle marker plot for $entry->{anno_name}\n";
	print "min:$min_anno\nmax:$max_anno\n";
	my $anno_color0 = $entry->{'anno_color'};
	my $anno_position0 = $entry->{'anno_position'};
	my $anno_height0 = $entry->{'anno_height'} - 0.1;
	my $min_max_value0 = $entry->{'min_max_value'};
	my $anno_opacity0 = $entry->{'opacity'} // 1;
    # 处理百分比
    $anno_opacity0 =~ s/%$//;
    $anno_opacity0 = 0.0 + $anno_opacity0 if $anno_opacity0;
    # 如果 min_max_value0 是区间 "(min:max)"
    my ($min_value0, $max_value0);
    if($min_max_value0 !~ /^(auto|normal|ratio)$/){
        ($min_value0, $max_value0) = parse_min_max("$min_max_value0");
        $min_value0 += 0; $max_value0 += 0;
    }
	my $genome_num = 0;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		foreach my $chr_name (sort keys %{$hashG})
		{
			$chr_num++;
			my @anno_line;
			my @anno_piont;
			my @ANNO_window;
			my $rect_x = $SVG_x;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
			if($anno_position0 eq 'top')
			{
				$rect_y -= ($anno_height0 + 0.05);
			}
			elsif($anno_position0 eq 'bottom')
			{
				$rect_y += ($ChrHight + 0.05);
			}
			##### annotation region
			my $CHR_anno = $hash_annoX1{$Gnum}->{$chr_name} // next;
			foreach my $start_anno (sort { $a <=> $b } keys %{$CHR_anno}) {
				foreach my $end_anno (sort { $a <=> $b } keys %{ $CHR_anno->{$start_anno} }) {
					my $anno_Win_size = abs($end_anno - $start_anno) + 1;
					my $value = $CHR_anno->{$start_anno}->{$end_anno};
					my $height_ratio;
					#if($value > 1){$min_max_value0 = 'normal';}
					#elsif($value < 1){$min_max_value0 = 'ratio';}
					my $X1 = ($rect_x + (($start_anno + $end_anno)/2) / $scale);
					my $Y1 = 0;
					my $X2 = $X1;
					my $Y2 = 0;
					if(($min_max_value0 eq 'normal')or($min_max_value0 eq 'ratio')or($min_max_value0 eq 'auto'))
					{
						if($anno_position0 eq 'top')
						{
							$Y1 = ($rect_y);
							$Y2 = ($rect_y + $anno_height0);
						}
						elsif($anno_position0 eq 'bottom')
						{
							$Y1 = ($rect_y + $Chrdottom);
							$Y2 = ($rect_y);
						}
						elsif($anno_position0 eq 'middle')
						{
							$Y1 = ($rect_y + 0.05);
							$Y2 = ($rect_y + $ChrHight - 0.05);
						}
						# print"$Gnum\t$chr_name\t\$X1:$X1\t\$Y1:$Y1\n";
						push @anno_line, [$X1, $Y1];
						push @anno_piont, [$X2, $Y2];
						push (@ANNO_window, $anno_Win_size);
					}
					else
					{
                        if(($anno_Win_size >= $min_value0) and ($anno_Win_size <= $max_value0))
						{
							if($anno_position0 eq 'top')
							{
								$Y1 = ($rect_y);
								$Y2 = ($rect_y + $anno_height0);
							}
							elsif($anno_position0 eq 'bottom')
							{
								$Y1 = ($rect_y + $Chrdottom);
								$Y2 = ($rect_y);
							}
							elsif($anno_position0 eq 'middle')
							{
								$Y1 = ($rect_y);
								$Y2 = ($rect_y + $ChrHight);
							}
							# print"$Gnum\t$chr_name\t\$X1:$X1\t\$Y1:$Y1\n";
							push @anno_line, [$X1, $Y1];
							push @anno_piont, [$X2, $Y2];
							push (@ANNO_window, $anno_Win_size);
						}
					}
					###print "Chr: $chr_name\tStart: $start_anno\tEnd: $end_anno\tValue: $value\n";
				}
			}
			for (my $i = 0; $i <= $#anno_line; $i++) {
				my ($x1, $y1) = @{$anno_line[$i]};
				my ($x2, $y2) = @{$anno_piont[$i]};
				my $window_ref = $ANNO_window[$i] / $scale;
				# 这里你可以绘制一条线段
				$SVG1->line(
					x1 => $x1, y1 => $y1,
					x2 => $x2, y2 => $y2,
					style  => {
						'fill'         => 'none',       # 不填充
						'stroke'       => "$anno_color0",       # 折线颜色
						'stroke-width' => "$window_ref",
						'stroke-opacity'   => "$anno_opacity0",
					}
				);
			}
		}
	}
}

sub draw_heatmap {
    my ($entry, $hash_Ginfo_ref, $genome_num_ref, $hash_annoX_ref, $max_anno, $min_anno, $SVG1) = @_;
	my %hash_annoX1 = %$hash_annoX_ref;
    print "Draw heatmap for $entry->{anno_name}\n";
	print "min:$min_anno\nmax:$max_anno\n";
	my $anno_color0 = $entry->{'anno_color'};
	my $anno_position0 = $entry->{'anno_position'};
	my $anno_height0 = $entry->{'anno_height'} - 0.1;
	my $min_max_value0 = $entry->{'min_max_value'};
	my $anno_opacity0 = $entry->{'opacity'} // 1;
    # 处理百分比
    $anno_opacity0 =~ s/%$//;
    $anno_opacity0 = 0.0 + $anno_opacity0 if $anno_opacity0;
    # 如果 min_max_value0 是区间 "(min:max)"
    my ($min_value0, $max_value0);
    if($min_max_value0 !~ /^(auto|normal|ratio)$/){
        ($min_value0, $max_value0) = parse_min_max("$min_max_value0");
        $min_value0 += 0; $max_value0 += 0;
    }
	my $genome_num = 0;
	foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
	{
		#my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		##### print"$Gnum:$Gname\n";
		my $hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
		my $chr_num = 0;
		$genome_num++;
		
		foreach my $chr_name (sort keys %{$hashG})
		{
			my $Glen = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
			$chr_num++;
			my @anno_line;
			my @anno_piont;
			my @ANNO_window;
			my @ANNO_value;
			my $rect_x = $SVG_x;
			my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
			if($anno_position0 eq 'top')
			{
				$rect_y -= ($anno_height0 + 0.05);
			}
			elsif($anno_position0 eq 'bottom')
			{
				$rect_y += ($ChrHight + 0.05);
			}
			##### annotation region
			my $CHR_anno = $hash_annoX1{$Gnum}->{$chr_name} // next;
			foreach my $start_anno (sort { $a <=> $b } keys %{$CHR_anno}) {
				foreach my $end_anno (sort { $a <=> $b } keys %{ $CHR_anno->{$start_anno} }) {
					my $anno_Win_size = abs($end_anno - $start_anno) + 1;
					my $value = $CHR_anno->{$start_anno}->{$end_anno};
					my $height_ratio;
					#if($value > 1){$min_max_value0 = 'normal';}
					#elsif($value < 1){$min_max_value0 = 'ratio';}
					if($min_max_value0 eq 'normal')
					{
						$height_ratio = $value / $anno_Win_size;
					}
					elsif($min_max_value0 eq 'ratio')
					{
						$height_ratio = $value;
					}
					elsif($min_max_value0 eq 'auto')
					{
						$height_ratio = ($value - $min_anno)/($max_anno - $min_anno);
					}
					else
					{
                        if($value > 1 ){$height_ratio = $value / $anno_Win_size;}
                        elsif($value < 1){$height_ratio = $value;}
                        $height_ratio = $height_ratio > $max_value0 ? $max_value0 : $height_ratio;
                        $height_ratio = $height_ratio < $min_value0 ? $min_value0 : $height_ratio;
						$height_ratio = ($height_ratio - $min_value0)/($max_value0 - $min_value0);
                        #print"\$max_value0:$max_value0;\$min_value0:$min_value0;\$value:$value;\$anno_Win_size:$anno_Win_size;\$height_ratio:$height_ratio\n";
					}
					###print "Chr: $chr_name\tStart: $start_anno\tEnd: $end_anno\tValue: $value\n";
					my $X1 = ($rect_x + (($start_anno + $end_anno)/2) / $scale);
					my $Y1 = 0;
					my $X2 = $X1;
					my $Y2 = 0;
					if($anno_position0 eq 'top')
					{
						$Y1 = ($rect_y);
						$Y2 = ($rect_y + $anno_height0);
					}
					elsif($anno_position0 eq 'bottom')
					{
						$Y1 = ($rect_y + $Chrdottom);
						$Y2 = ($rect_y);
					}
					elsif($anno_position0 eq 'middle')
					{
						$Y1 = ($rect_y + 0.05);
						$Y2 = ($rect_y + $ChrHight - 0.05);
					}
					# print"$Gnum\t$chr_name\t\$X1:$X1\t\$Y1:$Y1\n";
					push @anno_line, [$X1, $Y1];
					push @anno_piont, [$X2, $Y2];
					push(@ANNO_window,$anno_Win_size);
					push(@ANNO_value,$value);
				}
			}
			for (my $i = 0; $i <= $#anno_line; $i++) {
				my ($x1, $y1) = @{$anno_line[$i]};
				my ($x2, $y2) = @{$anno_piont[$i]};
				my $window_ref = $ANNO_window[$i] / $scale;
				my $value = $ANNO_value[$i] / $max_anno;
				my $gene_opacity;
				 #if($value<0.25){$gene_opacity=(0.10+0.15*$value);}
				 #elsif($value<0.5){$gene_opacity=(0.35+0.15*$value);}
				 #elsif($value<0.75){$gene_opacity=(0.6+0.15*$value);}
				 #else{$gene_opacity=(0.85+0.15*$value);}
				if ($value < 0.25) {
					$gene_opacity = 0.2 + 0.8 * $value;  # 最低 0.4
				} elsif ($value < 0.5) {
					$gene_opacity = 0.45 + 0.1 * $value;
				} elsif ($value < 0.75) {
					$gene_opacity = 0.65 + 0.15 * $value;
				} else {
					$gene_opacity = 0.85 + 0.15 * $value;  # 基本接近全不透明
				}
				if($gene_opacity > 1){$gene_opacity = 1;}
				# 这里你可以绘制一条线段
				$SVG1->line(
					x1 => $x1, y1 => $y1,
					x2 => $x2, y2 => $y2,
					style  => {
						'fill'         => 'none',       # 不填充
						'stroke'       => "$anno_color0",       # 折线颜色
						'stroke-width' => "$window_ref",
						'stroke-opacity'   => "$gene_opacity",
					}
				);
			}
			if($anno_position0 eq 'middle')
			{
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
				my $r_x = $ChrHight / 2 - 0.05;
				my $r_y = $ChrHight / 2 - 0.05;
				my $X1 = $rect_x - 0.5;
				my $Y1 = $rect_y + $ChrHight - 0.05;
				my $X2 = $X1;
				my $Y2 = $rect_y + 0.05;
				my $X3 = $rect_x + $ChrHight / 2;
				my $Y3 = $Y2;
				my $X4 = $X3;
				my $Y4 = $Y1;
				my $X5 = $rect_x + $ChrHight / 2;
				my $Y5 = $rect_y;
				my $X6 = $rect_x + $ChrHight / 2;
				my $Y6 = $rect_y + $ChrHight;
				$SVG1->path(
					d     => "M ${X1} ${Y1} L ${X2} ${Y2} L ${X3} ${Y3} A ${r_x} ${r_y} 0 0 0 ${X4} ${Y4} Z",
					style => {
						fill   => 'white',
						stroke => 'none',
						'stroke-width' => '0',
					},
				);
				$SVG1->path(
					d     => "M ${X6} ${Y6} A ${r_x} ${r_y} 0 0 1 ${X5} ${Y5}",
					style => {
						fill   => 'none',
						stroke => 'block',
						'stroke-width' => '0.1',
					},
				);
				$X1 = $rect_x + $Glen / $scale - $ChrHight / 2;
				$Y1 = $rect_y + $ChrHight - 0.05;
				$X2 = $X1;
				$Y2 = $rect_y + 0.05;
				$X3 = $X2 + $ChrHight / 2 + 0.5;
				$Y3 = $Y2;
				$X4 = $X3;
				$Y4 = $Y1;
				$X5 = $X1;
				$Y5 = $rect_y + $ChrHight;
				$X6 =  $X1;
				$Y6 = $rect_y;
				$SVG1->path(
					d     => "M ${X1} ${Y1} A ${r_x} ${r_y} 0 0 0 ${X2} ${Y2} L ${X3} ${Y3} L ${X4} ${Y4} Z",
					style => {
						fill   => 'white',
						stroke => 'none',
						'stroke-width' => '0',
					},
				);
				$SVG1->path(
					d     => "M ${X5} ${Y5} A ${r_x} ${r_y} 0 0 0 ${X6} ${Y6}",
					style => {
						fill   => 'none',
						stroke => 'block',
						'stroke-width' => '0.1',
					},
				);
			}
			
		}
	}
}

#绘制注释外边框
sub draw_anno_frame {
    my ($entry, $hash_annotype_ref, $anno_position_ref, $hash_Ginfo_ref, $genome_num_ref, $SVG1) = @_;
	my $anno_height0 = $entry->{'anno_height'};
	my %hash_annotype = %{$hash_annotype_ref};
	my @anno_position = @$anno_position_ref; # 解引用
	foreach my $anno_position0(@anno_position)
	{
		my $genome_num = 0;
		foreach my $Gnum (sort{$a<=>$b} keys %{$hash_Ginfo_ref})
		{
			my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
			my $hashG;
			$hashG = $hash_Ginfo_ref->{$Gnum}->{'chr'};
			my $chr_tags = $hash_Ginfo_ref->{$Gnum}->{'tags'}; #lw:1.5;color:#FF0000;opacity:1
			if (defined $chr_tags) 
			{
				if ($chr_tags =~ /height:([\d.]+)/) {$ChrHight = $1;}
				if ($chr_tags =~ /color:([^;]+)/) {$Chrcolor = $1;}
				if ($chr_tags =~ /opacity:([\d.]+)/) {$Chropacity = $1;}
			}
			my $chr_num = 0;
			$genome_num++;
			##### print"$Gnum:$Gname\n";
			foreach my $chr_name (sort keys %{$hashG})
			{
				$chr_num++;
				my $chr_len = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_num - 1) * $genome_num_ref * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height) + ($genome_num - 1) * ($Chrtop + $ChrHight + $Chrdottom + $synteny_height);
				if($anno_position0 eq 'top')
				{
					$rect_y -= $anno_height0;
				}
				elsif($anno_position0 eq 'bottom')
				{
					$rect_y += $anno_height0;
				}
				##### annotation frame
				my $chr_width = $chr_len / $scale;
				if(($anno_position0 eq 'top')or($anno_position0 eq 'bottom')or(($anno_position0 eq 'middle')and(defined $hash_annotype{'heatmap'})))
				{
					$SVG1 -> rect(
						 x => ($rect_x),
						 y => ($rect_y),
						 width => $chr_width,
						 height => $ChrHight,
						 style=>{
							 'fill'=>'#FFFFFF',#FFFFFF,none
							 'stroke'=>'black',
							 'stroke-width'=>'0.1',
						}
					);
				}
			}
		}
	}
}

sub gff3_TO_bed {
	my ($GnumX, $hash_Ginfo_ref, $file_anno, $hash_annoX_ref, $window_size, $anno_filter_type0) = @_;
	my $hash_GinfoX =$hash_Ginfo_ref->{$GnumX}->{'chr'};
	my %hash_output;
	my $anno_min;
	my $anno_max;
	foreach my $chr(sort keys %{$hash_GinfoX})
	{
		my $len = $hash_Ginfo_ref->{$GnumX}->{'chr'}->{$chr};
		my $Wnum;
		if($len % $window_size == 0){$Wnum = int($len / $window_size);}
		else{$Wnum = int($len / $window_size) + 1;}
		my $W_start = 1;
		for(my $i = 0;$i<$Wnum;$i++)
		{
			my $W_end = $window_size * ($i + 1);
			if($i == $Wnum-1){$W_end = $len;}
			$hash_output{$chr}->{$i}->{$W_start}->{$W_end} = 0;
			$W_start += $window_size;
		}
	}
	# 读取文件
	open my $in_gff3, '<', $file_anno or die "Cannot read input file $file_anno: $!\n";
	#print"Open $file_anno\n";
	while (my $line = <$in_gff3>) {
		chomp $line;
		next if $line =~ /^#/;     # 过滤掉注释行
		next if $line =~ /^\s*$/;  # 跳过空行
		# 按照GFF3格式解析
		my @fields = split /\t/, $line;
		my $filter = $fields[2];
		# 过滤
		if (($anno_filter_type0 eq 'none') or ($filter eq $anno_filter_type0)) {
			my $chr = $fields[0];    # 染色体
			my $G_start = $fields[3];  # 基因起始位置
			my $G_end = $fields[4];    # 基因结束位置
			my $G_length = abs($G_end - $G_start) + 1;
			my $G_start_num = int(($G_start - 1)/$window_size);
			my $G_end_num = int(($G_end - 1)/$window_size);
			if($G_start_num == $G_end_num)
			{
				my $hash_ref1 = $hash_output{$chr}->{$G_start_num};
				foreach my $W_start(keys %{$hash_ref1})
				{
					my $hash_ref2 = $hash_output{$chr}->{$G_start_num}->{$W_start};
					foreach my $W_end (keys %{$hash_ref2})
					{
						$hash_output{$chr}->{$G_start_num}->{$W_start}->{$W_end} += $G_length;
					}
				}
			}
			elsif($G_start_num < $G_end_num)
			{
				for(my $i= $G_start_num;$i <= $G_end_num; $i++)
				{
					my $lenX;
					if($i == $G_start_num){$lenX = ($i + 1) * $window_size - $G_start + 1;}
					elsif($i == $G_end_num){$lenX = $G_end - $i * $window_size + 1;}
					else{$lenX = $window_size;}
					my $hash_ref1 = $hash_output{$chr}->{$i};
					foreach my $W_start(keys %{$hash_ref1})
					{
						my $hash_ref2 = $hash_output{$chr}->{$i}->{$W_start};
						foreach my $W_end (keys %{$hash_ref2})
						{
							$hash_output{$chr}->{$i}->{$W_start}->{$W_end} += $lenX;
						}
					}
				}
			}
			elsif($G_start_num > $G_end_num)
			{
				for(my $i= $G_end_num;$i <= $G_start_num; $i++)
				{
					my $lenX;
					if($i == $G_end_num){$lenX = ($i + 1) * $window_size - $G_end + 1;}
					elsif($i == $G_start_num){$lenX = $G_start - $i * $window_size + 1;}
					else{$lenX = $window_size;}
					my $hash_ref1 = $hash_output{$chr}->{$i};
					foreach my $W_start(keys %{$hash_ref1})
					{
						my $hash_ref2 = $hash_output{$chr}->{$i}->{$W_start};
						foreach my $W_end (keys %{$hash_ref2})
						{
							$hash_output{$chr}->{$i}->{$W_start}->{$W_end} += $lenX;
						}
					}
				}
			}
		}
	}
	close $in_gff3;
	#输出
	foreach my $chr(sort keys %hash_output)
	{
		my $hash_ref1 = $hash_output{$chr};
		foreach my $Xnum (sort{$a<=>$b} keys %{$hash_ref1})
		{
			my $hash_ref2 = $hash_output{$chr}->{$Xnum};
			foreach my $W_start(sort keys %{$hash_ref2})
			{
				my $hash_ref3 = $hash_output{$chr}->{$Xnum}->{$W_start};
				foreach my $W_end(sort keys %{$hash_ref3})
				{
					my $W_len = $hash_output{$chr}->{$Xnum}->{$W_start}->{$W_end};
					#if($W_len != 0)
					{
						# 更新最大值
						if (!defined $anno_max || $W_len > $anno_max) {
							$anno_max = $W_len;
						}
						# 更新最小值
						if (!defined $anno_min || $W_len < $anno_min) {
							$anno_min = $W_len;
						}
						if($W_len > $window_size){$W_len = $window_size;}
						$hash_annoX_ref->{$GnumX}->{$chr}->{$W_start}->{$W_end} = $W_len;
						# print"$chr\t$W_start\t$W_end\t$W_len\n";
					}
				}
			}
		}
	}
	return ($anno_min, $anno_max);  # 返回最小值和最大值
}

sub bed_to_newWindows {
	my ($GnumX, $hash_Ginfo_ref, $window_size, $hash_annoY_ref) = @_;
	my $hash_GinfoX =$hash_Ginfo_ref->{$GnumX}->{'chr'};
	my %hash_output;
	my %hash_outputX;
	my $anno_min;
	my $anno_max;
	foreach my $chr(sort keys %{$hash_GinfoX})
	{
		my $len = $hash_Ginfo_ref->{$GnumX}->{'chr'}->{$chr};
		my $Wnum;
		if($len % $window_size == 0){$Wnum = int($len / $window_size);}
		else{$Wnum = int($len / $window_size) + 1;}
		my $W_start = 1;
		for(my $i = 0;$i<$Wnum;$i++)
		{
			my $W_end = $window_size * ($i + 1);
			if($i == $Wnum-1){$W_end = $len;}
			$hash_output{$chr}->{$i}->{$W_start}->{$W_end} = 0;
			$W_start += $window_size;
		}
	}
	my %hash_ANNO1 = %$hash_annoY_ref;
	my $hash_annoY1 = $hash_ANNO1{$GnumX};
	foreach my $chr(sort keys %{$hash_annoY1})
	{
		my $hash_annoY2 = $hash_ANNO1{$GnumX}->{$chr};
		foreach my $anno_start(sort keys %{$hash_annoY2})
		{
			my $hash_annoY3 = $hash_ANNO1{$GnumX}->{$chr}->{$anno_start};
			foreach my $anno_end(sort keys %{$hash_annoY3})
			{
				my $value = $hash_ANNO1{$GnumX}->{$chr}->{$anno_start}->{$anno_end};
				my $start_num = int(($anno_start - 1) / $window_size);
				my $end_num = int(($anno_end - 1) / $window_size);
				if($start_num == $end_num)
				{
					my $hash_ref1 = $hash_output{$chr}->{$start_num};
					foreach my $W_start(keys %{$hash_ref1})
					{
						my $hash_ref2 = $hash_output{$chr}->{$start_num}->{$W_start};
						foreach my $W_end (keys %{$hash_ref2})
						{
							$hash_output{$chr}->{$start_num}->{$W_start}->{$W_end} += $value;
						}
					}
				}
			}
		}
	}
	foreach my $chr(sort keys %hash_output)
	{
		my $hash_ref1 = $hash_output{$chr};
		foreach my $Xnum (sort{$a<=>$b} keys %{$hash_ref1})
		{
			my $hash_ref2 = $hash_output{$chr}->{$Xnum};
			foreach my $W_start(sort keys %{$hash_ref2})
			{
				my $hash_ref3 = $hash_output{$chr}->{$Xnum}->{$W_start};
				foreach my $W_end(sort keys %{$hash_ref3})
				{
					my $W_len = $hash_output{$chr}->{$Xnum}->{$W_start}->{$W_end};
					#if($W_len != 0)
					{
						# 更新最大值
						if (!defined $anno_max || $W_len > $anno_max) {
							$anno_max = $W_len;
						}
						# 更新最小值
						if (!defined $anno_min || $W_len < $anno_min) {
							$anno_min = $W_len;
						}
						if($W_len > $window_size){$W_len = $window_size;}
						$hash_outputX{$GnumX}->{$chr}->{$W_start}->{$W_end} = $W_len;
						# print"$chr\t$W_start\t$W_end\t$W_len\n";
					}
				}
			}
		}
	}
	return ($anno_min, $anno_max, \%hash_outputX);
}

sub parse_min_max {
    my ($str) = @_;
    return unless defined $str;

    # 去掉首尾空格
    $str =~ s/^\s+|\s+$//g;

    # 去掉括号 ( ) 如果有
    $str =~ s/^\(//;
    $str =~ s/\)$//;

    # 解析 "min:max"
    if ($str =~ /^([+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)
                  \s*:\s*
                  ([+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)$/x) {
        my ($min, $max) = ($1, $2);
        # 检查逻辑合理性
        if ($min > $max) {
            die "Error: invalid range [$str] — min ($min) is greater than max ($max)\n";
        }
        elsif ($min == $max) {
            warn "Warning: min and max are equal in [$str]; range is zero.\n";
        }
        # 检查是否在 0-1 范围内
        if ($min < 0 || $min > 1 || $max < 0 || $max > 1) {
            die "Error: range values must be within [0,1]. Got min=$min, max=$max from [$str]\n";
        }
        return ($min + 0, $max + 0);  # 强制数字化
    }
    else {
        die "Error: Invalid min:max format [$str]. Expect like 0.4:0.5 or (0.4:0.5)\n";
    }
}

# 子函数：数值转带单位的字符串，并去掉多余的小数点和0
sub num2char {
    my ($num) = @_;
    my $precision ||= 2;  # 默认保留 2 位小数

    my $result;
    if    ($num >= 1_000_000_000) {
        $result = sprintf("%.${precision}fGb", $num / 1_000_000_000);
    }
    elsif ($num >= 1_000_000) {
        $result = sprintf("%.${precision}fMb", $num / 1_000_000);
    }
    elsif ($num >= 1_000) {
        $result = sprintf("%.${precision}fKb", $num / 1_000);
    }
    else {
        $result = sprintf("%.${precision}fb", $num);
    }

    # 去掉多余的小数点和0，例如 1.00Mb -> 1Mb, 1.50Mb -> 1.5Mb
	$result =~ s/(\.\d*?)0+(?=[KMG]?b\b)//;  # 去掉多余0
	$result =~ s/\.([KMG]?b)/$1/;            # 去掉多余小数点

    return $result;
}

sub read_vcf_output {
	my ($vcf, $vcf_out1, $vcf_out2, $vcf_out3) = @_;
	my %contig_len;
	my %sample_color;
	my %SNP_density;
	my %SNP_identity;
	my %sample_index;
	open(my $IN,  "<", $vcf)  or die "Cannot open $vcf: $!";
	while (<$IN>) {
		chomp;
		next if /^\s*$/;  # 可选：跳过空行
		my @cols = split(/\t/, $_);

		# 读取注释行
		if ($_ =~ /^#/) {
			#print $OUT $_, "\n";
			# 解析 contig 信息
			if (/^##contig=<(.+)>/) {
				my $info = $1;   # ID=Chr01,length=45027022
				my ($id)  = $info =~ /ID=([^,>]+)/;
				my ($len) = $info =~ /length=(\d+)/;
				if ($id && $len) {
					$contig_len{$id} = $len;
					my $len_out = commify($len);
					print "Contig: ID=$id, length=$len_out\n";
				}
			}
			# 解析 color 信息
			elsif (/^##color=<(.+)>/) {
				my $info = $1;   # Sample=NIP,color="#39A5D6"
				my ($sample) = $info =~ /Sample=([^,>]+)/;
				my ($color)  = $info =~ /color="([^"]+)"/;
				if ($sample && $color) {
					$sample_color{$sample} = $color;
					print "Color: Sample=$sample, color=\"$color\"\n";
				}
			}
			elsif(/^#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT/)
			{
				for my $i (9 .. $#cols) {
					$sample_index{$i} = $cols[$i]; # 在VCF中列的编号 => 样本名
				}
			}
			next;  # 继续读取下一行
		}
		# 遇到非注释且非空行，终止读取
		last;
	}
	close $IN;

	my $color_snp_off = 0;
	if (! keys %contig_len) {
		die "Error: VCF file format is incomplete!\n".
			"Please add contig information in the VCF header, for example:\n".
			"##contig=<ID=Chr01,length=45027022>\n";
	}
	if (! keys %sample_color) {
		#warn "Warning: VCF file format is incomplete!\n";
		warn "Warning: Please add color information in the VCF header, for example:\n";
		my $COUNT_color = 0;
		foreach my $i (sort{$a<=>$b} keys %sample_index)
		{
			my $Sample1 = $sample_index{$i};
			my $sample_color1 = $default_color[$COUNT_color % $n_colors];# 循环使用颜色
			warn "##color=<Sample=$Sample1,color=\"$sample_color1\">\n";
			$COUNT_color++;
		}
		#warn "##color=<Sample=NIP,color=\"#39A5D6\">\n";
		warn "\n";
		$color_snp_off = 1;
	}

	my $COUNT_color = 0;
	if($color_snp_off == 1)
	{
		foreach my $i (sort{$a<=>$b} keys %sample_index)
		{
			my $Sample = $sample_index{$i};
			$sample_color{$Sample} = $default_color[$COUNT_color % $n_colors];# 循环使用颜色
			$COUNT_color++;
		}
	}

	# step1: 初始化%SNP_density，所有 bin 区间
	foreach my $chr (keys %contig_len) {
		my $chr_len = $contig_len{$chr};
		for (my $pos = 1; $pos <= $chr_len; $pos += $bin_size) {
			my $start = $pos;
			my $end   = $pos + $bin_size - 1;
			$end = $chr_len if $end > $chr_len;

			# 初始化所有样本为0
			foreach my $i (sort{$a<=>$b} keys %sample_index)
			{
				my $sample = $sample_index{$i};
				$SNP_density{$chr}->{$start}->{$end}->{$sample} = 0
					unless defined $SNP_density{$chr}->{$start}->{$end}->{$sample};
			}
		}
	}
	# step2: 初始化%SNP_identity，所有 bin 区间
	foreach my $chr (keys %contig_len) {
		my $chr_len = $contig_len{$chr};
		for (my $pos = 1; $pos <= $chr_len; $pos += $bin_size) {
			my $start = $pos;
			my $end   = $pos + $bin_size - 1;
			$end = $chr_len if $end > $chr_len;

			# 初始化所有样本为0
			foreach my $i (sort{$a<=>$b} keys %sample_index)
			{
				my $sample = $sample_index{$i};
				$SNP_identity{$chr}->{$start}->{$end}->{$sample} = 0
					unless defined $SNP_identity{$chr}->{$start}->{$end}->{$sample};
			}
		}
	}

	open($IN,  "<", $vcf)  or die "Cannot open $vcf: $!";
	open(my $OUT, ">", $vcf_out1) or die "Cannot open $vcf_out1: $!";
	while (<$IN>) {
		chomp;
		next if /^\s*$/;  # 可选：跳过空行
		my @cols = split(/\t/, $_);

		# 读取注释行
		if ($_ =~ /^#/) { print $OUT $_, "\n"; }
		else
		{
			my $count_cols = scalar(@cols);
			my $Num = int(($cols[1] - 1) / $bin_size);  # bin 索引
			my $start = $Num * $bin_size + 1;
			my $end = ($Num + 1) * $bin_size;
			if($end > $contig_len{$cols[0]}){$end = $contig_len{$cols[0]};}
			for(my $i = 9;$i<$count_cols;$i++)
			{
				my $Sample1 = $sample_index{$i};
				my ($gt) = split(/:/, $cols[$i]);  # 取 : 前的部分
				if(($gt ne './.')and($gt ne '0/0')and($gt ne '.')and($gt ne '0')) 
				{
					$SNP_density{$cols[0]}->{$start}->{$end}->{$Sample1} += 1;
				}
			}
			#最后一列是子代
			my ($gt_child) = split(/:/, $cols[-1]);  # 取 : 前的部分
			# print "Child GT: $gt_child\n";
			#my @cols = @cols;
			#if(($gt_child ne './.')and($gt_child ne '0/0')and($gt_child ne '.')and($gt_child ne '0')) #去除最后一列(子代)未分型的
			if(($gt_child ne './.')and($gt_child ne '.')) #去除最后一列(子代)未分型的
			{
				for(my $i = 9;$i<$count_cols;$i++)
				{
					if (defined $cols[$i]) {
						my ($gt) = split(/:/, $cols[$i]);  # 取 : 前的部分
						if (!defined $gt || $gt eq ".") {
							$cols[$i] = "-9999/-9999";
						} elsif ($gt =~ /^\d+$/) {
							$cols[$i] = "$gt/$gt"; # 如果 $gt 是纯数字，比如 0、1、2、3、4、5、6、7、8、9 ...
						} elsif ($gt =~ /^\d+\|\d+$/) {
							$cols[$i] =~ s/\|/\//g;  # 转换 phased 到 unphasedggg
						} elsif ($gt eq "./.") {
							$cols[$i] = "-9999/-9999";
						} else {
							#$cols[$i] = $gt; # 其他情况保持原始 GT（比如 0/1、1/2 这种杂合）
							my @linex = map { $_ eq "." ? -9999 : $_ } split('/', $cols[$i]);
							@linex = sort { $a <=> $b } @linex;
							$cols[$i] = join('/', @linex);
						}
					}
				}
				
				# 亲本基因型放到哈希去重
				my @check_cols = @cols[9..($count_cols - 2)];
				my %seen1;
				$seen1{$_}++ for @check_cols;
				##确认亲本SNP基因型至少为两类
				#my $diff_count = $count_cols - 9 - 1;
				my $diff_off = 0;
				if(keys %seen1 > 1){$diff_off = 1;}
				else{$diff_off = 0;}
				
				my @merge_parent;
				for(my $i = 9;$i<($count_cols - 1);$i++)
				{
					my @linex = split('/', $cols[$i]);
					push(@merge_parent,@linex);
				}
				{ my %seen; @merge_parent = sort { $a <=> $b } grep { !$seen{$_}++ } @merge_parent; }
				my @child = map { $_ eq "." ? -9999 : $_ } split('/', $cols[($count_cols - 1)]);
				{ my %seen; @child = sort { $a <=> $b } grep { !$seen{$_}++ } @child; }
				my $value = scalar(@child);
				my $count = 0;
				foreach my $key1(@child)
				{
					foreach my $key2(@merge_parent)
					{
						if($key1 == $key2){$count++;}
					}
				}
				if(($count == $value)and($diff_off == 1)) #if($count == $value)
				{
					#%SNP_identity;
					$SNP_identity{$cols[0]}->{$start}->{$end}->{COUNT} += 1;
					my $copy_num =0;
					for(my $i = 9;$i<($count_cols-1);$i++)
					{
						if($cols[$i] eq $cols[-1]){$copy_num++;}
					}
					for(my $i = 9;$i<($count_cols-1);$i++)
					{
						my $Sample1 = $sample_index{$i};
						if($cols[$i] eq $cols[-1])
						{
							$SNP_identity{$cols[0]}->{$start}->{$end}->{$Sample1} += 1/$copy_num;
						}
					}
					@cols = map { $_ eq '-9999/-9999' ? './.' : $_ } @cols;
					print $OUT join("\t", @cols), "\n";
				}
				elsif(($value == 2)and($diff_off == 1))
				{
					my $copy_num =0;
					$SNP_identity{$cols[0]}->{$start}->{$end}->{COUNT} += 1;
					for(my $i = 9;$i<($count_cols-1);$i++)
					{
						#if($cols[$i] eq $cols[-1]){$copy_num++;}
						my @parent1 = split('/',$cols[$i]);
						my %seen_p;
						@parent1 = grep { !$seen_p{$_}++ } @parent1;   # 去重
						@parent1 = sort { $a <=> $b } @parent1;      # 排序
						my $value_p = scalar(@parent1);
						if($value_p==1)
						{
							foreach my $child1(@child)
							{
								if($child1 eq $parent1[0]){$copy_num++;}
							}
						}
					}
					for(my $i = 9;$i<($count_cols-1);$i++)
					{
						my $Sample1 = $sample_index{$i};
						my @parent1 = split('/',$cols[$i]);
						my %seen_p;
						@parent1 = grep { !$seen_p{$_}++ } @parent1;   # 去重
						@parent1 = sort { $a <=> $b } @parent1;      # 排序
						my $value_p = scalar(@parent1);
						foreach my $child1(@child)
						{
							if($value_p==1)
							{
								if($child1 eq $parent1[0])
								{
									$SNP_identity{$cols[0]}->{$start}->{$end}->{$Sample1} += 1/$copy_num;
								}
							}
						}
					}
					@cols = map { $_ eq '-9999/-9999' ? './.' : $_ } @cols;
					print $OUT join("\t", @cols), "\n";
				}
			}
		}
	}
	close $IN;
	close $OUT;
	print "1. Filtered sites with clear parental origin: $vcf_out1\n";

	my @arr_Sample_list;
	foreach my $i (sort{$a<=>$b} keys %sample_index)
	{
		my $Sample = $sample_index{$i};
		push(@arr_Sample_list, $Sample);
	}
	my $Sample_list = join("\t",@arr_Sample_list);
	#my $sample_add2 = '.SNP_count';
	open(my $OUT2, ">", $vcf_out2) or die "Cannot open $vcf_out2: $!";
	#print $OUT2 "#Chr\tStart\tEnd\t$Sample_list$sample_add2\n";
	print $OUT2 "#Chr\tStart\tEnd\t$Sample_list\n";
	foreach my $CHR (sort keys %contig_len)
	{
		my $hash1 = $SNP_density{$CHR};
		foreach my $start (sort{$a<=>$b} keys %{$hash1})
		{
			my $hash2 = $SNP_density{$CHR}->{$start};
			foreach my $end (sort{$a<=>$b} keys %{$hash2})
			{
				my $hash3 = $SNP_density{$CHR}->{$start}->{$end};
				my @arr_value;
				foreach my $i (sort{$a<=>$b} keys %sample_index)
				{
					my $Sample = $sample_index{$i};
					$SNP_density{$CHR}->{$start}->{$end}->{$Sample} = ($SNP_density{$CHR}->{$start}->{$end}->{$Sample} // 0);
					my $Value = $SNP_density{$CHR}->{$start}->{$end}->{$Sample};
					push(@arr_value, $Value);
				}
				my $Value_join = join("\t",@arr_value);
				print $OUT2 "$CHR\t$start\t$end\t$Value_join\n";
			}
		}
	}
	close $OUT2;
	print "2. SNP density statistics: $vcf_out2\n";

	my @sorted_keys = sort { $a <=> $b } keys %sample_index;
	my $count_num1 = scalar(@sorted_keys);
	#pop @sorted_keys;   # 去掉最后一个元素
	my @arr2list;
	foreach my $i (@sorted_keys)
	{
		my $Sample = $sample_index{$i};
		push( @arr2list, $Sample);
	}
	my $Sample_list2 = join("\t", @arr2list);
	#my $sample_add = '.SNP_count';
	open(my $OUT3, ">", $vcf_out3) or die "Cannot open $vcf_out3: $!";
	#print $OUT3 "#Chr\tStart\tEnd\t$Sample_list2$sample_add\n";
	print $OUT3 "#Chr\tStart\tEnd\t$Sample_list2\n";
	foreach my $CHR (sort keys %contig_len)
	{
		my $hash1 = $SNP_identity{$CHR};
		foreach my $start (sort{$a<=>$b} keys %{$hash1})
		{
			my $hash2 = $SNP_identity{$CHR}->{$start};
			foreach my $end (sort{$a<=>$b} keys %{$hash2})
			{
				my $hash3 = $SNP_identity{$CHR}->{$start}->{$end};
				my @arr_value;
				$SNP_identity{$CHR}->{$start}->{$end}->{COUNT} = ($SNP_identity{$CHR}->{$start}->{$end}->{COUNT} // 0);
				my $COUNT1 = $SNP_identity{$CHR}->{$start}->{$end}->{COUNT};
				my $num00 = 0;
				my $num_countall = 0;
				my $num_countallout = 0;
				foreach my $i (@sorted_keys)
				{
					$num00++;
					my $Sample = $sample_index{$i};
					$SNP_identity{$CHR}->{$start}->{$end}->{$Sample} = ($SNP_identity{$CHR}->{$start}->{$end}->{$Sample} // 0);
					my $Value = $SNP_identity{$CHR}->{$start}->{$end}->{$Sample};
					my $rounded = sprintf("%.2f", $Value) + 0;
					$num_countall += $rounded;
					if($num00==$count_num1)
					{
						$num_countallout = sprintf("%.0f", $num_countall);
						$rounded = $num_countallout;
					}
					push(@arr_value, $rounded);
				}
				my $jX = $sorted_keys[-1];
				my $childX = $sample_index{$jX};
				$SNP_identity{$CHR}->{$start}->{$end}->{$childX} = $num_countallout;
				my $Value_join = join("\t",@arr_value);
				print $OUT3 "$CHR\t$start\t$end\t$Value_join\n";
			}
		}
	}
	close $OUT3;
	print "3. SNP consistency statistics: $vcf_out3\n";

    # 最后 return 五个 hash 引用
    #return (\%contig_len, \%sample_color, \%SNP_density, \%SNP_identity, \%sample_index);
}

sub draw_vcf_chr_block {
	#my ($SVG1, $hash_Ginfo_ref, $genome_num_ref, $tel_width, ) = @_;
	my ($SVG1, $contig_len_ref, $sample_color_ref, $SNP_density_ref, $SNP_identity_ref, $sample_index_ref) = @_;
	my $chr_number = 0;
	my $max_identity = 0;
	if(defined $SNP_identity_ref)
	{
		my $bin_len = 0;
		my $move_x = 0;
		foreach my $CHR (sort keys %{$contig_len_ref})
		{
			foreach my $start (sort keys %{$SNP_identity_ref->{$CHR}})
			{
				foreach my $end (sort keys %{$SNP_identity_ref->{$CHR}->{$start}})
				{
					#my $COUNT = 0;
					my $count_all = scalar keys %{$sample_index_ref};
					my $j = 0;
					#my $value0 = $SNP_identity_ref->{$CHR}->{$start}->{$end}->{COUNT};
					#print"$count_all:$CHR\t$start\t$end\t$value0\n";
					foreach my $i (sort{$a<=>$b} keys %{$sample_index_ref})
					{
						$j++;
						#$COUNT++;
						#my $sample = $sample_index_ref->{$i};
						#print "$j:$sample\t";
						if($j == $count_all)
						{
							my $sample = $sample_index_ref->{$i};
							my $value = $SNP_identity_ref->{$CHR}->{$start}->{$end}->{$sample};
							#print": $value";
							#$value_max = $value > $value_max ? $value : $value_max;
							if($value > $max_identity){$max_identity = $value;}
						}
					}
					#print"\n";
				}
			}
		}
	}
	my %hash_density_color;
	my %hash_identity_color;
	#区间计数
	my %hash_ratio_density;
	my %hash_ratio_identity;
	my %hash_ratio_merge;
	foreach my $CHR (sort keys %{$contig_len_ref})
	{
		$chr_number++;
		my $chr_len = $contig_len_ref->{$CHR};
		##### print "$chr_name\t$chr_len\n";
		my $rect_x = $SVG_x;
		my $rect_y = $SVG_y + 2 + $Chrtop + ($chr_number - 1) * ($Chrtop + $ChrHight + $Chrdottom) + ($Chrtop + $ChrHight + $Chrdottom);
		if($chr_number == 1){draw_scale_axis($SVG1, $chr_len, $rect_x, $rect_y - 2 - $Chrtop);}
		##### chromosome region
		my $chr_width = $chr_len / $scale;
		my $chr_r = $ChrHight/2;
		$chr_r = $chr_r;
		$SVG1 -> rect(
			 x => ($rect_x),
			 y => ($rect_y),
			 width => $chr_width,
			 height => $ChrHight,
			 style=>{
				 'fill'=>'#FFFFFF',
				 'stroke'=>'none',
				 'rx'=>"$chr_r",
				 'ry'=>"$chr_r",
				 'stroke-width'=>'0',
			}
		);
		my $X1 = ($rect_x - 2);
		$SVG1 -> text(
			 x => $X1,
			 y => ($rect_y + $ChrHight*3/4),
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'end',   # 可为 start | middle | end
			}
		)->cdata("$CHR");
		if(defined $SNP_density_ref)
		{
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y - $ChrHight),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'#FFFFFF',
					 'stroke'=>'none',
					 'stroke-width'=>'0.1',
				}
			);
			my %hash_line;
			my $Y_min = 1e12;
			my $Y_max = 0;
			#my %hash_density_color;
			#foreach my $CHR (sort keys %{$SNP_density_ref})
			{
				my $countX = 0;
				foreach my $start (sort{$a<=>$b} keys %{$SNP_density_ref->{$CHR}})
				{
					foreach my $end (sort{$a<=>$b} keys %{$SNP_density_ref->{$CHR}->{$start}})
					{
						$countX++;
						my @sorted_keys = sort { $a <=> $b } keys %{$sample_index_ref};
						my $last_key    = $sorted_keys[-1];                 # 取最后一个键
						my $last_sample  = $sample_index_ref->{$last_key};   # 取对应的样品
						my $last_value = $SNP_density_ref->{$CHR}->{$start}->{$end}->{$last_sample};
						my $count_all = scalar keys %{$sample_index_ref};
						my $j = 0;
						my $min_diff_value = 1e12;
						my $sample_like = 'NA';
						my @arr_value;
						foreach my $i (sort{$a<=>$b} keys %{$sample_index_ref})
						{
							$j++;
							my $sample = $sample_index_ref->{$i};
							my $value = $SNP_density_ref->{$CHR}->{$start}->{$end}->{$sample};
							my $len = abs($end - $start) || 1;  # 避免除 0
							my $density_ratio = $value / $len;
							$Y_min = $density_ratio > $Y_min ? $Y_min : $density_ratio;
							$Y_max = $Y_max > $density_ratio ? $Y_max : $density_ratio;
							if($j != $count_all)
							{
								my $diff_value = abs($value - $last_value);
								if($min_diff_value > $diff_value)
								{
									$min_diff_value = $diff_value;
									$sample_like = $sample;
								}
								push(@arr_value, $diff_value);
							}
							my $X1 = ($start + $end)/2;
							$hash_line{$sample}->{$countX} = "$X1" . ':' . "$density_ratio";
						}
						my %seen;
						my @unique = grep { !$seen{$_}++ } @arr_value;
						my $count_uniq = scalar(@unique);
						$hash_ratio_density{all_bin_count}++;
						if($count_uniq == 1){$hash_density_color{$CHR}->{$start}->{$end} = 'NA';}
						else
						{
							$hash_density_color{$CHR}->{$start}->{$end} = $sample_like;
							$hash_ratio_density{$sample_like}++;
						}
					}
				}
			}
			foreach my $i (sort{$a<=>$b} keys %{$sample_index_ref})
			{
				my $sample = $sample_index_ref->{$i};
				my $color = $sample_color_ref->{$sample};
				my @arr_sample_keys = sort { $a <=> $b } keys %{$hash_line{$sample}};
				my $countAA = scalar(@arr_sample_keys);
				my @arr_polyline;
				foreach my $countX1 (sort{$a<=>$b} keys %{$hash_line{$sample}})
				{
					if(0){
						if($countX1 < $countAA)
						{
							my $countX2 = $countX1 + 1;
							my $siteXY1 = $hash_line{$sample}->{$countX1};
							my $siteXY2 = $hash_line{$sample}->{$countX2};
							my ($X1, $Y1) = split(':', $siteXY1);
							my ($X2, $Y2) = split(':', $siteXY2);
							my $x1 = $rect_x + $X1 / $scale;
							my $y1 = $rect_y - $ChrHight * ($Y1 - $Y_min)/($Y_max - $Y_min);
							my $x2 = $rect_x + $X1 / $scale;
							my $y2 = $rect_y - $ChrHight * ($Y2 - $Y_min)/($Y_max - $Y_min);
							# 这里你可以绘制一条线段
							$SVG1->line(
								x1 => $x1, y1 => $y1,
								x2 => $x2, y2 => $y2,
								style  => {
									'fill'         => 'none',       # 不填充
									'stroke'       => "$color",       # 折线颜色
									'stroke-width' => 0.1,
									'stroke-opacity'   => 0.8,
								}
							);
						}
					}
					{
						my $siteXY1 = $hash_line{$sample}->{$countX1};
						my ($X1, $Y1) = split(':', $siteXY1);
						my $x1 = $rect_x + $X1 / $scale;
						my $y1 = $rect_y - (($ChrHight - $ChrHight/5) - 0.2) * ($Y1 - $Y_min)/($Y_max - $Y_min) - 0.1 - $ChrHight/5;
						#my $y1 = $rect_y + 1;
						my $xy_merge = "$x1" . ',' . "$y1";
						push(@arr_polyline, $xy_merge);
					}
				}
				my $arr_line = join(' ', @arr_polyline);
				my $count_dot = scalar(@arr_polyline);
				#print"$sample\t$CHR\t$count_dot\n";
				$SVG1->polyline(
					 points=>"$arr_line",
					 style=>{
						 'fill'=>'none',
						 'stroke'=>"$color",  
						 'stroke-opacity'   => 1,
						 'stroke-width'=> 0.05,
						 'stroke-linejoin'=> 'round',   # 拐角圆角
						 'stroke-linecap' => 'round',   # 端点圆角（可选）
					}
				);
			}
			my %hash_density_color2;
			my $prev_sample;
			my $merged_start = 0;
			my $merged_end   = 0;
			foreach my $start (sort{$a<=>$b} keys %{$hash_density_color{$CHR}})
			{
				foreach my $end (sort{$a<=>$b} keys %{$hash_density_color{$CHR}->{$start}})
				{
					my $sample = $hash_density_color{$CHR}->{$start}->{$end};
					if (!defined $prev_sample)
					{
						$merged_start = $start;
						$merged_end   = $end;
						$prev_sample  = $sample;
					}
					elsif($sample eq $prev_sample)
					{
						$merged_end   = $end;#XXXXXX
					}
					else
					{
						$hash_density_color2{$CHR}{$merged_start}{$merged_end} = $prev_sample;
						$prev_sample  = $sample;
						$merged_start = $start;
						$merged_end   = $end;
					}
				}
			}
			$hash_density_color2{$CHR}{$merged_start}{$merged_end} = $prev_sample;
			foreach my $start (sort{$a<=>$b} keys %{$hash_density_color2{$CHR}})
			{
				foreach my $end (sort{$a<=>$b} keys %{$hash_density_color2{$CHR}->{$start}})
				{
					my $sample = $hash_density_color2{$CHR}->{$start}->{$end};
					if($sample ne 'NA')
					{
						my $color = $sample_color_ref->{$sample};
						my $move_x = $start / $scale;
						my $color_len = abs($end - $start) / $scale;
						$SVG1 -> rect(
							 x => ($rect_x + $move_x),
							 #y => ($rect_y + 0.1),
							 y => ($rect_y + 0.1 - $ChrHight/5),
							 width => $color_len,
							 #height => $ChrHight - 0.2,
							 height => $ChrHight/5 - 0.2,
							 style=>{
								 'fill'=>$color,
								 'stroke'=>'none',
								 'stroke-width'=>'0',
								 'fill-opacity'=> 0.8,   # 0 = 全透明, 1 = 不透明
							}
						);
					}
				}
			}
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y - $ChrHight),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'none',
					 'stroke'=>'black',
					 'stroke-width'=>'0.1',
				}
			);
		}

		if(defined $SNP_identity_ref)
		{
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y + $ChrHight),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'#FFFFFF',
					 'stroke'=>'none',
					 'stroke-width'=>'0',
				}
			);
			if(0){
				$SVG1->line(
					x1 => $rect_x, y1 => $rect_y + $ChrHight + $Chrdottom/2,
					x2 => $rect_x + $chr_width, y2 => $rect_y + $ChrHight + $Chrdottom/2,
					style  => {
						'fill'         => 'none',       # 不填充
						'stroke'       => "#333333",       # 折线颜色
						'stroke-width' => 0.05,
						'stroke-opacity'   => 0.1,
					}
				);
			}
			my $bin_len = 0;
			my $move_x = 0;
			my $rect_identity_x = $rect_x;
			#foreach my $CHR (sort keys %{$SNP_identity_ref})
			{
				foreach my $start (sort keys %{$SNP_identity_ref->{$CHR}})
				{
					foreach my $end (sort keys %{$SNP_identity_ref->{$CHR}->{$start}})
					{
						my $COUNT = 0;
						my $value_max = 0;
						my $sample_max = '';
						my $count_all = scalar keys %{$sample_index_ref};
						my $j = 0;
						foreach my $i (sort{$a<=>$b} keys %{$sample_index_ref})
						{
							$j++;
							if($j != $count_all)
							{
								my $sample = $sample_index_ref->{$i};
								my $value = $SNP_identity_ref->{$CHR}->{$start}->{$end}->{$sample};
								#$value_max = $value > $value_max ? $value : $value_max;
								if($value > $value_max)
								{
									$value_max = $value;
									$sample_max = $sample;
								}
								$COUNT += $value;
							}
						}
						#if($COUNT==0){die "COUNT is zero!\n";}
						$move_x = $start / $scale;
						$rect_identity_x = $rect_x + $move_x;
						$hash_ratio_identity{all_bin_count}++;
						if($COUNT != 0)
						{
							#my $max_identity = 0;
							#my $parent_ratio = $value_max / $COUNT;
							my $parent_ratio = $value_max / $max_identity;
							my $height_diff = $ChrHight * (1 - $parent_ratio) / 2 + 0.1;
							my $ratio_height = ($ChrHight - 0.2) * $parent_ratio;
							$bin_len = ($end - $start) / $scale;
							my $color = $sample_color_ref->{$sample_max};
							$SVG1 -> rect(
								 x => $rect_identity_x,
								 y => ($rect_y + $height_diff + $ChrHight),
								 width => $bin_len,
								 height => $ratio_height,
								 style=>{
									 'fill'=>$color,
									 'stroke'=>'none',
									 'stroke-width'=>'0',
									 'fill-opacity'=> 0.8,   # 0 = 全透明, 1 = 不透明
								}
							);
							#$move_x = $start / $scale;
							#my $XXXXS = $rect_y + $height_diff;
							#print"$CHR\t$start\t$end\t$ratio_height:$rect_x-$XXXXS\n";
							$hash_identity_color{$CHR}->{$start}->{$end} = $sample_max;
							$hash_ratio_identity{$sample_max}++;
						}
						else{$hash_identity_color{$CHR}->{$start}->{$end} = 'NA';}
					}
				}
			}
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y + $ChrHight),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'none',
					 'stroke'=>'black',
					 'stroke-width'=>'0.1',
				}
			);
		}
		my %hash_priority_color;
		if((defined $SNP_identity_ref)and(defined $SNP_density_ref))
		{
			foreach my $start (sort{$a<=>$b} keys %{$SNP_density_ref->{$CHR}})
			{
				foreach my $end (sort{$a<=>$b} keys %{$SNP_density_ref->{$CHR}->{$start}})
				{
					my $sample_density = $hash_density_color{$CHR}->{$start}->{$end};
					my $sample_identity = $hash_identity_color{$CHR}->{$start}->{$end};
					$hash_ratio_merge{all_bin_count}++;
					if($type_priority eq 'unite')
					{
						if($sample_density eq $sample_identity)
						{
							$hash_priority_color{$CHR}->{$start}->{$end} = $sample_density;
							$hash_ratio_merge{$sample_density}++;
						}
						else{$hash_priority_color{$CHR}->{$start}->{$end} = 'NA';}
					}
					elsif($type_priority eq 'density')
					{
						if($sample_density ne 'NA')
						{
							$hash_priority_color{$CHR}->{$start}->{$end} = $sample_density;
							$hash_ratio_merge{$sample_density}++;
						}
						elsif($sample_density eq 'NA')
						{
							if($sample_identity ne 'NA')
							{
								$hash_priority_color{$CHR}->{$start}->{$end} = $sample_identity;
								$hash_ratio_merge{$sample_identity}++;
							}
							else{$hash_priority_color{$CHR}->{$start}->{$end} = 'NA';}
						}
					}
					elsif($type_priority eq 'identity')
					{
						if($sample_identity ne 'NA')
						{
							$hash_priority_color{$CHR}->{$start}->{$end} = $sample_identity;
							$hash_ratio_merge{$sample_identity}++;
						}
						elsif($sample_identity eq 'NA')
						{
							if($sample_density ne 'NA')
							{
								$hash_priority_color{$CHR}->{$start}->{$end} = $sample_density;
								$hash_ratio_merge{$sample_density}++;
							}
							else{$hash_priority_color{$CHR}->{$start}->{$end} = 'NA';}
						}
					}
				}
			}
			my %hash_priority_color2;
			my $prev_sample;
			my $merged_start = 0;
			my $merged_end   = 0;
			foreach my $start (sort{$a<=>$b} keys %{$hash_priority_color{$CHR}})
			{
				foreach my $end (sort{$a<=>$b} keys %{$hash_priority_color{$CHR}->{$start}})
				{
					my $sample = $hash_priority_color{$CHR}->{$start}->{$end};
					if (!defined $prev_sample)
					{
						$merged_start = $start;
						$merged_end   = $end;
						$prev_sample  = $sample;
					}
					elsif($sample eq $prev_sample)
					{
						$merged_end   = $end;#XXXXXX
					}
					else
					{
						$hash_priority_color2{$CHR}{$merged_start}{$merged_end} = $prev_sample;
						$prev_sample  = $sample;
						$merged_start = $start;
						$merged_end   = $end;
					}
				}
			}
			$hash_priority_color2{$CHR}{$merged_start}{$merged_end} = $prev_sample;
			foreach my $start (sort{$a<=>$b} keys %{$hash_priority_color2{$CHR}})
			{
				foreach my $end (sort{$a<=>$b} keys %{$hash_priority_color2{$CHR}->{$start}})
				{
					my $sample = $hash_priority_color2{$CHR}->{$start}->{$end};
					if($sample ne 'NA')
					{
						my $color = $sample_color_ref->{$sample};
						my $move_x = $start / $scale;
						my $color_len = abs($end - $start) / $scale;
						$SVG1 -> rect(
							 x => ($rect_x + $move_x),
							 y => ($rect_y + 0.1),
							 #y => ($rect_y + 0.1 - $ChrHight/5),
							 width => $color_len,
							 height => $ChrHight - 0.2,
							 #height => $ChrHight/5 - 0.2,
							 style=>{
								 'fill'=>$color,
								 'stroke'=>'none',
								 'stroke-width'=>'0',
								 'fill-opacity'=> 0.8,   # 0 = 全透明, 1 = 不透明
							}
						);
					}
				}
			}
		}
		#综合分型,绘图外框
		{
			my $r_x = ($ChrHight - 0.1) / 2;
			my $r_y = ($ChrHight - 0.1) / 2;
			my $X1 = $rect_x - 0.1;
			my $Y1 = $rect_y + $ChrHight - 0.05;
			my $X2 = $X1;
			my $Y2 = $rect_y + 0.05;
			my $X3 = $X2 + $r_x + 0.05 + 0.1;
			my $Y3 = $Y2;
			my $X4 = $X3;
			my $Y4 = $Y1;
			$SVG1->path(
				d     => "M ${X1} ${Y1} L ${X2} ${Y2} L ${X3} ${Y3} A ${r_x} ${r_y} 0 0 0 ${X4} ${Y4} Z",
				style => {
					fill   => 'white',
					stroke => 'none',
					'stroke-width' => '0',
				},
			);
			$X1 = $rect_x + $chr_width - $ChrHight / 2 + 0.05;
			$Y1 = $rect_y + $ChrHight - 0.05;
			$X2 = $X1;
			$Y2 = $rect_y + 0.05;
			$X3 = $X2 + $r_x + 0.1;
			$Y3 = $Y2;
			$X4 = $X3;
			$Y4 = $Y1;
			$SVG1->path(
				d     => "M ${X1} ${Y1} A ${r_x} ${r_y} 0 0 0 ${X2} ${Y2} L ${X3} ${Y3} L ${X4} ${Y4} Z",
				style => {
					fill   => 'white',
					stroke => 'none',
					'stroke-width' => '0',
				},
			);
			$SVG1 -> rect(
				 x => ($rect_x),
				 y => ($rect_y),
				 width => $chr_width,
				 height => $ChrHight,
				 style=>{
					 'fill'=>'none',
					 'stroke'=>'black',
					 'rx'=>"$chr_r",
					 'ry'=>"$chr_r",
					 'stroke-width'=>'0.1',
				}
			);
		}
	}
	#my %hash_ratio_density;
	#my %hash_ratio_identity;
	#my %hash_ratio_merge;
	if((defined $SNP_identity_ref)and(defined $SNP_density_ref))
	{
		my $count_all = scalar keys %{$sample_index_ref};
		my $count_chr = scalar(keys %{$contig_len_ref});
		my $table_width = 20;
		#my $table_width = $SVG_main/($count_all + 1);
		#my $gap_len = $table_width;
		my $gap_len = 20;
		my $table_w1 = 22;
		my $rect_x = $SVG_x + $SVG_main/2 - $count_all/2 * $table_width + $table_width + $table_width/2 + 2;
		#my $rect_y = $SVG_y + 2 + $Chrtop + $count_chr * ($Chrtop + $ChrHight + $Chrdottom);
		my $rect_y = $SVG_y - $ChrHight;
		my $Y_density = 0;
		my $Y_identity = 0;
		my $out_nametype = 'Merge';
		if($type_priority eq 'unite'){$Y_density = $ChrHight;$Y_identity = $ChrHight*2;$out_nametype = 'Unite';}
		elsif($type_priority eq 'density'){$Y_density = $ChrHight;$Y_identity = $ChrHight*2;}
		elsif($type_priority eq 'identity'){$Y_density = $ChrHight*2;$Y_identity = $ChrHight;}
		$SVG1 -> text(
			 x => $rect_x - $table_w1,
			 y => $rect_y - $ChrHight,
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'middle',   # 可为 start | middle | end
			}
		)->cdata('Name');
		$SVG1 -> text(
			 x => $rect_x - $table_w1,
			 y => $rect_y,
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'middle',   # 可为 start | middle | end
			}
		)->cdata("$out_nametype");
		$SVG1 -> text(
			 x => $rect_x - $table_w1,
			 y => $rect_y + $Y_density,
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'middle',   # 可为 start | middle | end
			}
		)->cdata('SNP density');
		$SVG1 -> text(
			 x => $rect_x - $table_w1,
			 y => $rect_y + $Y_identity,
			 style => {
				'font-family' => 'Arial', #"Courier",
				'stroke'      => 'none',
				'font-size'   => '4',
				'text-anchor' => 'middle',   # 可为 start | middle | end
			}
		)->cdata('SNP identity');
		# 表格第1条线
		$SVG1->line(
			x1 => $rect_x - $table_w1*1.5 - 1, y1 => $rect_y + 1.5 - $ChrHight*2,
			x2 => $rect_x - $table_w1*1.5 + $table_width * $count_all + 1, y2 => $rect_y + 1 - $ChrHight*2,
			style  => {
				'fill'         => 'none',       # 不填充
				'stroke'       => "block",       # 折线颜色
				'stroke-width' => 0.5,
				'stroke-opacity'   => 1,
			}
		);
		# 表格第2条线
		$SVG1->line(
			x1 => $rect_x - $table_w1*1.5 - 1, y1 => $rect_y + 1.5 - $ChrHight,
			x2 => $rect_x - $table_w1*1.5 + $table_width * $count_all + 1, y2 => $rect_y + 1 - $ChrHight,
			style  => {
				'fill'         => 'none',       # 不填充
				'stroke'       => "block",       # 折线颜色
				'stroke-width' => 0.1,
				'stroke-opacity'   => 1,
			}
		);
		# 表格第3条线
		$SVG1->line(
			x1 => $rect_x - $table_w1*1.5 - 1, y1 => $rect_y + 1.5 + $ChrHight*2,
			x2 => $rect_x - $table_w1*1.5 + $table_width * $count_all + 1, y2 => $rect_y + 1 + $ChrHight*2,
			style  => {
				'fill'         => 'none',       # 不填充
				'stroke'       => "block",       # 折线颜色
				'stroke-width' => 0.5,
				'stroke-opacity'   => 1,
			}
		);
		my $j = 0;
		#$rect_x += $table_width/2;
		print"\nName[Color]\tMerge\tSNP identity\tSNP density\n";
		foreach my $i (sort{$a<=>$b} keys %{$sample_index_ref})
		{
			$j++;
			if($j != $count_all)
			{
				my $sample = $sample_index_ref->{$i};
				my $color = $sample_color_ref->{$sample};
				my $value_density = sprintf("%.2f", (100*$hash_ratio_density{$sample}/$hash_ratio_density{all_bin_count})) + 0;
				my $value_identity = sprintf("%.2f", (100*$hash_ratio_identity{$sample}/$hash_ratio_identity{all_bin_count})) + 0;
				my $value_merge = sprintf("%.2f", (100*$hash_ratio_merge{$sample}/$hash_ratio_merge{all_bin_count})) + 0;
				my $out_density = $value_density . '%';
				my $out_identity = $value_identity . '%';
				my $out_merge = $value_merge . '%';
				my $rect_width = 16;
				my $rect_height = 3.5;
				$SVG1 -> rect(
					 x => $rect_x + $i * $gap_len - $rect_width/2,
					 y => $rect_y - $ChrHight - $rect_height + 0.4,
					 width => $rect_width,
					 height => $rect_height,
					 style=>{
						 'fill'=>$color,
						 'stroke'=>'none',
						 'stroke-width'=>'0',
						 'fill-opacity'=> 0.8,   # 0 = 全透明, 1 = 不透明
					}
				);
				$SVG1 -> text(
					 x => $rect_x + $i * $gap_len,
					 y => $rect_y - $ChrHight,
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'middle',   # 可为 start | middle | end
					}
				)->cdata("$sample");
				$SVG1 -> text(
					 x => $rect_x + $i * $gap_len,
					 y => $rect_y,
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'middle',   # 可为 start | middle | end
					}
				)->cdata("$out_merge");
				$SVG1 -> text(
					 x => $rect_x + $i * $gap_len,
					 y => $rect_y + $Y_density,
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'middle',   # 可为 start | middle | end
					}
				)->cdata("$out_density");
				$SVG1 -> text(
					 x => $rect_x + $i * $gap_len,
					 y => $rect_y + $Y_identity,
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'middle',   # 可为 start | middle | end
					}
				)->cdata("$out_identity");
				print"$sample\[$color\]\t$out_merge\t$out_identity\t$out_density\n";
			}
		}
	}
}

sub drawing_SVG2 {
	 my ($config_ref,$global_max,$global_min,$Gname_max_num,$chrname_max_num,$chr_num_min,$genome_num_ref) = @_;
	$SVG_x = $SVG_x_left + $Gname_max_len + $chrname_max_len + 2;
	$SVG_y = $SVG_x_top;
	my $genome_num = 0;
	my $len_count_max = 0;
	my %hash_chr_max_len;
	foreach my $Gnum (sort{$a<=>$b} keys %hash_Ginfo)
	{
		my $Gname = $hash_Ginfo{$Gnum}->{'name'};
		my $hashGX = $hash_read_chr_order{$Gnum};
		my @arr_chr = sort{$hashGX->{$a} <=> $hashGX->{$b}} keys %{$hashGX};
		$genome_num++;
		my $chr_len_countX = 0;
		foreach my $chr_name (@arr_chr)
		{
			 my $chr_num = $hash_read_chr_order{$Gnum}->{$chr_name};
			 my $chr_len = $hash_Ginfo{$Gnum}->{'chr'}->{$chr_name};
			 #print"\$Gnum:$Gnum:\$chr_num:$chr_num:\$chr_len:$chr_len:\$chr_name:$chr_name\n";
			 if($genome_num == 1)
			 {
			     $hash_chr_max_len{$chr_num} = $chr_len;
			 }
			 else
			 {
				 if($chr_len > $hash_chr_max_len{$chr_num})
				 {
				     $hash_chr_max_len{$chr_num} = $chr_len;
				 }
			 }

		}
	}

	my $chrnum_count_max = (sort { $a <=> $b } keys %hash_chr_max_len)[-1];
	foreach my $chr_num (sort{$a<=>$b} keys %hash_chr_max_len)
	{
		my $chr_len_max = $hash_chr_max_len{$chr_num};
		$len_count_max += $chr_len_max;
	}
	my $chr_gap_len = 1;

	$scale2 = $len_count_max/($SVG2_main - ($chrnum_count_max-1) * $chr_gap_len);
	#print"\$scale2:$scale2\n";
	#Canvas size
	my $SVG2= SVG -> new();
	my $SVG2_canvas_w = sprintf("%.0f", $SVG2_main + $SVG_x + $SVG_x_right + 15);
	my $SVG2_canvas_h = sprintf("%.0f", $ChrHight * $genome_num + $synteny_height * $genome_num + $SVG_x_top);
	$SVG2= SVG -> new(width => $SVG2_canvas_w . 'mm', height   => $SVG2_canvas_h . 'mm', viewBox => "0 0 $SVG2_canvas_w $SVG2_canvas_h");
	print"\ndrawing_SVG2\nCanvas width: $SVG2_canvas_w mm\n";
	print"Canvas height: $SVG2_canvas_h mm\n";

	#绘制共线性块
	draw_syn2_block($SVG2,\%hash_syninfo,\%hash_Ginfo,$syntent_type,$genome_num,\%hash_chr_max_len,$chr_gap_len);
	#绘制染色体块及刻度线
	draw_chr2_block($SVG2,\%hash_Ginfo,$genome_num,\%hash_chr_max_len,$chr_gap_len);

	my $svg_file = $config_ref->{'save_info'}->{'savefig2'};
	my $svg_pdf = 1;
	if($svg_file =~ /\.pdf$/i){ $svg_file =~ s/\.pdf$/.svg/i; $svg_pdf = 2;}
	if($svg_file =~ /\.png$/i){ $svg_file =~ s/\.png$/.svg/i; $svg_pdf = 3;}
	elsif($svg_file =~ /\.svg$/i){}
	else{$svg_file .= '.svg'; $svg_pdf = 2;}
	# 输出绘图文件
	open my $svg_fh, '>', $svg_file or die "无法写入 $svg_file: $!";
	print $svg_fh $SVG2->xmlify(), "\n";
	close $svg_fh;
	my $pdf_file = '';
	if(($svg_pdf == 2)or($svg_pdf == 3))
	{
		# 先生成目标文件名
		my $tmp_pdf = $svg_file;
		if($svg_pdf == 2){$tmp_pdf =~ s/\.svg$/.pdf/i;}
		elsif($svg_pdf == 3){$tmp_pdf =~ s/\.svg$/.png/i;}
		# 调用 CairoSVG 转换
		if (system("cairosvg $svg_file -o $tmp_pdf") == 0) {
			# 转换成功时，才更新 $pdf_file
			$pdf_file = $tmp_pdf;
		}
		else {
			#warn "转换失败：$!";
			warn "Conversion failed: $!";
		}
		return $tmp_pdf;
	}
}

sub draw_syn2_block {
	my ($SVG2, $hash_syninfo_ref, $hash_Ginfo_ref, $syn_type,$genome_num_ref,$hash_chr_max_len_ref,$chr_gap_len) = @_;
	my $genome_num = 0;
	my $off_SYN = 0;
	my $off_INV = 0;
	my $off_TRANS = 0;
	my $off_INVTR = 0;
    # 读取共线性信息文件
	foreach my $Syn_num(sort{$a<=>$b} keys %{$hash_syninfo_ref})
	{
		$genome_num++;
		my $ref_genome   = $genome_num;
		my $query_genome = $genome_num + 1;
		my $Syn_align = $hash_syninfo_ref->{$Syn_num}->{'align'};
		open my $FL_align, "<", $Syn_align or die "Cannot open $Syn_align: $!";
		while(<$FL_align>)
		{
			chomp;
			next if /^#/;  # 跳过以 # 开头的注释行
			next if /^\s*$/;  # 跳过空行
			my @tem = split /\t/;
			my $chrR = $tem[0];
			my $chrQ = $tem[3];
			my $chr_lenR = $hash_Ginfo_ref->{$ref_genome}->{'chr'}->{$chrR};
			my $chr_lenQ = $hash_Ginfo_ref->{$query_genome}->{'chr'}->{$chrQ};
			my $GnameR = $hash_Ginfo_ref->{$ref_genome}->{'name'};
			my $GnameQ = $hash_Ginfo_ref->{$query_genome}->{'name'};
			my ($startR, $endR, $startQ, $endQ);
			#my $strandR = $chr_orient{$ref_genome}->{$chrR};
			#my $strandQ = $chr_orient{$query_genome}->{$chrQ};
			my $strandR = '+';
			my $strandQ = '+';
			if (exists $hash_read_chr_order{$ref_genome}->{$chrR} && exists $hash_read_chr_order{$query_genome}->{$chrQ})
			{
				if($strandR eq '+')
				{
					$startR = $tem[1];
					$endR   = $tem[2];
					#print"$GnameR:$chr_lenR:$tem[1]\t$tem[2]\n";
					#print"$startR:$endR:$strandR\n";
				}
				elsif($strandR eq '-')
				{
					$startR = $chr_lenR - $tem[2] + 1;
					$endR   = $chr_lenR - $tem[1] + 1;
					#print"$GnameR:$chr_lenR:$tem[1]\t$tem[2]\n";
					#print"$startR:$endR:$strandR\n";
				}
				if($strandQ eq '+')
				{
					$startQ = $tem[4];
					$endQ   = $tem[5];
					#print"$GnameQ:$chr_lenQ:$tem[4]\t$tem[5]\n";
					#print"$startQ\t$endQ:$strandQ\n";
				}
				elsif($strandQ eq '-')
				{
					$startQ = $chr_lenQ - $tem[5] + 1;
					$endQ   = $chr_lenQ - $tem[4] + 1;
					#print"$GnameQ:$chr_lenQ:$tem[4]\t$tem[5]\n";
					#print"$startQ\t$endQ:$strandQ\n";
				}
				my $strand = $tem[6];
				if($strandR ne $strandQ)
				{
					if($strand eq '+'){$strand = '-';}
					elsif($strand eq '-'){$strand = '+';}
				}
				if($strand eq '+'){$strand = 1;}
				elsif($strand eq '-'){$strand = 0;}
				#my $strand = (($startR < $endR) == ($startQ < $endQ)) ? 1 : 0;
				my $Rnum = $hash_read_chr_order{$ref_genome}->{$chrR} - 1;
				my $Qnum = $hash_read_chr_order{$query_genome}->{$chrQ} - 1;
				my $chrlen_maxR = 0;
				my $chrlen_maxQ = 0;
				if($Rnum != 0)
				{
					my $chr_lenX = 0;
					for(my $j=1;$j<=$Rnum;$j++)
					{
						$chr_lenX += $hash_chr_max_len_ref->{$j}/$scale2;
					}
					$chrlen_maxR = $chr_lenX + $Rnum * $chr_gap_len;
				}
				if($Qnum != 0)
				{
					my $chr_lenX = 0;
					for(my $j=1;$j<=$Qnum;$j++)
					{
						$chr_lenX += $hash_chr_max_len_ref->{$j}/$scale2;
					}
					$chrlen_maxQ = $chr_lenX + $Qnum * $chr_gap_len;
				}
				my $rect_x = $SVG_x;
				my $rect_y = $SVG_y + 2 + $ChrHight + ($genome_num - 1) * ($ChrHight + $synteny_height);
				my $X1 = sprintf("%.2f", $rect_x + $chrlen_maxR + $startR / $scale2);
				my $Y1 = sprintf("%.2f", $rect_y);
				my $X2 = sprintf("%.2f", $rect_x + $chrlen_maxR + $endR / $scale2);
				my $Y2 = sprintf("%.2f", $rect_y);
				my $X3 = sprintf("%.2f", $rect_x + $chrlen_maxQ + $endQ / $scale2);
				my $Y3 = sprintf("%.2f", $rect_y + $synteny_height);
				my $X4 = sprintf("%.2f", $rect_x + $chrlen_maxQ + $startQ / $scale2);
				my $Y4 = sprintf("%.2f", $rect_y + $synteny_height);
				my $X1t = sprintf("%.2f", $X1);
				if($X1==$X2){$X1 = $X1 - 0.01;$X2 = $X2 + 0.01;}
				if($X3==$X4){$X3 = $X3 + 0.01;$X4 = $X4 - 0.01;}
				my $Y1t = sprintf("%.2f", $Y1 - $ChrHight/2);
				my $X2t = sprintf("%.2f", $X2);
				my $Y2t = sprintf("%.2f", $Y2 - $ChrHight/2);
				my $X3t = sprintf("%.2f", $X3);
				my $Y3t = sprintf("%.2f", $Y3 + $ChrHight/2);
				my $X4t = sprintf("%.2f", $X4);
				my $Y4t = sprintf("%.2f", $Y4 + $ChrHight/2);
				#my $fill_color = $strand == 1 ? "#DFDFE1" : "#E56C1A";
				#my $fill_color = $strand == 1 ? "$synteny_color" : "$inversion_color";
				my $fill_color = $synteny_color;
				if($hash_read_chr_order{$ref_genome}->{$chrR} eq $hash_read_chr_order{$query_genome}->{$chrQ})
				{
					$fill_color = $strand == 1 ? "$synteny_color" : "$inversion_color";
					if($strand == 1){$off_SYN = 1;}
					else{$off_INV = 1;}
				}
				else
				{
					my $NAME_GchrR = "$hash_chrGAI{$ref_genome}->{$chrR}";
					my $NAME_GchrQ = "$hash_chrGAI{$query_genome}->{$chrQ}";
					my @arr_nameR;
					my @arr_nameQ;
					# 判断 $NAME_GchrR 是否包含 '#'
					if (index($NAME_GchrR, '#') != -1) {@arr_nameR = split('#', $NAME_GchrR);}
					else {@arr_nameR = ($NAME_GchrR,'none10085');}
					if (index($NAME_GchrQ, '#') != -1) {@arr_nameQ = split('#', $NAME_GchrQ);}
					else {@arr_nameQ = ($NAME_GchrQ,'none10086');}
					if($arr_nameR[1] ne $arr_nameQ[1])
					{
						$fill_color = $strand == 1 ? "$translocation_color" : "$translocation2_color";
						if($strand == 1){$off_TRANS = 1;}
						else{$off_INVTR = 1;}
					}
					elsif($arr_nameR[1] eq $arr_nameQ[1])
					{
						$fill_color = $strand == 1 ? "$synteny_color" : "$inversion_color";
						if($strand == 1){$off_SYN = 1;}
						else{$off_INV = 1;}
					}
				}
				
				if($strand == 0)
				{
					$X3 = sprintf("%.2f", $rect_x + $chrlen_maxQ + $startQ / $scale2);
					$Y3 = sprintf("%.2f", $rect_y + $synteny_height);
					$X4 = sprintf("%.2f", $rect_x + $chrlen_maxQ + $endQ / $scale2);
					$Y4 = sprintf("%.2f", $rect_y + $synteny_height);
					if($X3==$X4){$X3 = $X3 - 0.01;$X4 = $X4 + 0.01;}
					$X3t = sprintf("%.2f", $X3);
					$Y3t = sprintf("%.2f", $Y3 + $ChrHight/2);
					$X4t = sprintf("%.2f", $X4);
					$Y4t = sprintf("%.2f", $Y4 + $ChrHight/2);
				}
				my $Y13 = ($Y1+$Y3)/2;
				my $Y24 = ($Y2+$Y4)/2;
				my $Y23 = ($Y2+$Y3)/2;
				my $Y14=($Y1+$Y4)/2;
				my $path;
				if ($syn_type eq 'line')
				{
					$SVG2->polygon(
						points => #"$X1,$Y1 $X2,$Y2 $X3,$Y3 $X4,$Y4",
								$X1.','. $Y1.' '. 
								$X1t.','. $Y1t.' '.
								$X2t.','. $Y2t.' '.
								$X2.','. $Y2.' '.
								$X3.','. $Y3.' '.
								$X3t.','. $Y3t.' '.
								$X4t.','. $Y4t.' '.
								$X4.','. $Y4.'',
						style  => {
							'fill' => $fill_color,
							'fill-opacity' => 0.8,
							'stroke' => $fill_color,
							'stroke-width' => '0',
						}
					);
				}
				elsif($syn_type eq 'curve')
				{
					 $path = "M $X1 $Y1 L $X1t $Y1t L $X2t $Y2t L $X2 $Y2 C $X2 $Y23 $X3 $Y23 $X3 $Y3 L $X3t $Y3t L $X4t $Y4t L $X4 $Y4 C $X4 $Y14 $X1 $Y14 $X1 $Y1 Z";
					 $SVG2->path(
						 d => $path,
						 style  => {
							 'fill' => $fill_color,
							 'fill-opacity' => 0.8,
							 'stroke' => $fill_color,
							 'stroke-width'=>'0',
						 }
					);
				}
			}
		}

		close $FL_align;
	}
	my $name_SYN = 'Synteny';
	my $name_INV = 'Inversion';
	my $name_TRANS = 'Translocation';
	my $name_INVTR = 'Inverted Translocation';
	my $legend_gap = 50;
	my $legend_width0 = 10;
	my $legend_width_gap = 2;
	my $SVG_legend_H = $ChrHight;
	my $X_legend = $SVG_x;
	my $Y_legend = $SVG_y - $ChrHight;
	my @arrlegend_off1 = ($off_SYN,$off_INV,$off_TRANS,$off_INVTR);
	my @arrlegend_color1 = ($synteny_color,$inversion_color,$translocation_color,$translocation2_color);
	my @arrlegend_name1 = ($name_SYN,$name_INV,$name_TRANS,$name_INVTR);
	for(my $j=0;$j<=3;$j++)
	{
		my $offX = $arrlegend_off1[$j];
		my $name_legend = $arrlegend_name1[$j];
		my $color_legend = $arrlegend_color1[$j];
		if($offX==1)
		{
			$SVG2 -> rect(
				 x => ($X_legend),
				 y => ($Y_legend - $SVG_legend_H),
				 width => $legend_width0,
				 height => $SVG_legend_H,
				 style=>{
					 'fill'=>"$color_legend",
					 'stroke'=>'none',
					 'stroke-width'=>'0',
				}
			);
			$SVG2 -> text(
				 x => ($X_legend + $legend_width0 + $legend_width_gap),
				 y => ($Y_legend - 1),
				 style => {
					'font-family' => 'Arial', #"Courier",
					'stroke'      => 'none',
					'font-size'   => '4',
					'text-anchor' => 'start',   # 可为 start | middle | end
				}
			)->cdata("$name_legend");
			$X_legend += $legend_gap;
		}
	}	
}

sub draw_chr2_block {
	my ($SVG2, $hash_Ginfo_ref, $genome_num_ref,$hash_chr_max_len_ref,$chr_gap_len) = @_;
	#my %aligned_order;  # 存储每个基因组的染色体顺序（最终与 G1 对齐）
	# 输出最终对齐顺序
	foreach my $Gnum (sort { $a <=> $b } keys %{$hash_Ginfo_ref})
	{
		my $Gname = $hash_Ginfo_ref->{$Gnum}->{'name'};
		my $chr_tags = $hash_Ginfo_ref->{$Gnum}->{'tags'} // "height:5;opacity:0.8;color:'#39A5D6';"; #lw:1.5;color:#FF0000;opacity:1
		my $hashG = $hash_read_chr_order{$Gnum};
		if (defined $chr_tags) 
		{
			if ($chr_tags =~ /height:\s*['"]?([\d.]+)['"]?/){$ChrHight = $1;}
			if ($chr_tags =~ /opacity:\s*['"]?([\d.]+)['"]?/){$Chropacity = $1;}
			if ($chr_tags =~ /color:\s*['"]?([^'";]+)['"]?/){$Chrcolor = $1;}
		}
		my @arr_chr = sort{$hashG->{$a} <=> $hashG->{$b}} keys %{$hashG};   # 用哈希键名代表染色体列表
		my $chr_number = 0;
		foreach my $chr_name(@arr_chr)
		{
			$chr_number++;
			my $chr_len = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name};
			my $numX = $chr_number - 1;
			my $chrlen_maxX = 0;
			if($numX != 0)
			{
				my $chr_lenX = 0;
				for(my $j=1;$j<=$numX;$j++)
				{
					$chr_lenX += $hash_chr_max_len_ref->{$j}/$scale2;
				}
				$chrlen_maxX = $chr_lenX + $numX * $chr_gap_len;
			}
			##### print "$chr_name\t$chr_len\n";
			my $rect_x = $SVG_x + $chrlen_maxX;
			#my $rect_y = $SVG_y + 2 + $Chrtop + ($Gnum - 1) * ($ChrHight + $synteny_height);
			my $rect_y = $SVG_y + 2 + ($Gnum - 1) * ($ChrHight + $synteny_height);
			##### chromosome region
			my $chr_width = $chr_len / $scale2;
			my $chr_r = $ChrHight/4;
			$chr_r = $chr_r;
			my $NAME_Gchr = "$hash_chrGAI{$Gnum}->{$chr_name}";
			if ($NAME_Gchr =~ /\*$/) {}
			else
			{
				my @arr_name = split('#',$NAME_Gchr);
				$SVG2 -> rect(
					 x => ($rect_x),
					 y => ($rect_y),
					 width => $chr_width,
					 height => $ChrHight,
					 style=>{
						 'fill'=>'#FFFFFF',
						 'stroke'=>'#FFFFFF',
						 'rx'=>"$chr_r",
						 'ry'=>"$chr_r",
						 'stroke-width'=>'0.1',
					}
				);
				$SVG2 -> rect(
					 x => ($rect_x),
					 y => ($rect_y),
					 width => $chr_width,
					 height => $ChrHight,
					 style=>{
						 'fill'=>"$Chrcolor",
						 'fill-opacity'   => "$Chropacity",
						 'stroke'=>'black',
						 'rx'=>"$chr_r",
						 'ry'=>"$chr_r",
						 'stroke-width'=>'0.1',
					}
				);
				my $chrlen_maxXY = $hash_Ginfo_ref->{$Gnum}->{'chr'}->{$chr_name}/($scale2*2);
				$SVG2 -> text(
					 x => $rect_x + $chrlen_maxXY,
					 y => ($rect_y + $ChrHight*3/4),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'middle',   # 可为 start | middle | end
					}
				)->cdata("$arr_name[0]");
			}

			if($chr_number == 1)
			{
				$SVG2 -> text(
					 x => ($rect_x - 2),
					 y => ($rect_y + $ChrHight*3/4),
					 style => {
						'font-family' => 'Arial', #"Courier",
						'stroke'      => 'none',
						'font-size'   => '4',
						'text-anchor' => 'end',   # 可为 start | middle | end
					}
				)->cdata("$Gname");
			}
		}
	}
}

__END__


=head1 NAME:

GenomeSyn2 - A Comparative Genomics Framework Integrating Synteny Visualization

=head1 SYNOPSIS:

 *************************************************************************************
 * Quick start:  GenomeSyn2 --align mummer --genome ./fa_data/ --outdir ./output/ --thread 30
 *               GenomeSyn2 --align blastp --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30
 *************************************************************************************
  1) Show this help message:
     GenomeSyn2 --help
  2) Show the full manual page with detailed documentation:
     GenomeSyn2 --man
  3) One-step run command:
     GenomeSyn2 --align mummer/minimap2 --genome ./fa_data/ --outdir ./output/ --thread 30
	 GenomeSyn2 --align blastp/mmseqs/diamond --genome ./fa_data/ --gene ./gene_data/ --outdir ./output/ --thread 30
  4) Calculate SNP density and SNP identity from a VCF file to visualize multi-parental origin contributions:
     GenomeSyn2 --vcf ./parents.progeny.snps.genotype.vcf --bin 50000
  5) Based on SNP density and SNP identity statistics, plot the multi-parental origins contribution:
     GenomeSyn2 --identity ./SNP_identity.50Kb.bed --density ./SNP_density.50Kb.bed
  6) Generate a file information table based on the given path and file type, for use in downstream alignment or analysis:
     GenomeSyn2 --type anno --path ./your_path/ --out anno.info.tsv
  7) Display and modify the Configuration:
     GenomeSyn2 --conf ? > total.conf
	 GenomeSyn2 --anno ? >> total.conf
  8) Run GenomeSyn2 using the Configuration file for full pipeline execution:
     GenomeSyn2 --conf total.conf

=head1 OPTIONS:

=over 4

=item B<--align>

Specifies the alignment software to be used: <mummer/minimap2/blastp/mmseqs/diamond>

=item B<--genome <dir>>

Path to the directory containing one or more genome FASTA files

Filenames should be preprocessed to start with an Arabic numeral followed by a dot (e.g., 1.G1.fa, 2.G2.fa). 

The program will sort the files numerically for downstream alignment and visualization.

=item B<--gene <dir>>

Specify the output directory for alignment result files.

=item B<--thread <int>>

Number of threads to use for parallel processing (default: 1).

=item B<--vcf <vcf>>

Input VCF file containing SNP genotypes.

=item B<--bin <int>>

Bin size (genomic window) to calculate SNP density and SNP identity.

=item B<--identity <bed>>

BED file containing precomputed SNP identity information across bins.

=item B<--density <bed>>

BED file containing precomputed SNP density information across bins.

=item B<--type>

Type of input data: <fa|prot|anno>

fa    - genome sequences or chromosome length (FASTA/bed)

prot  - protein sequences (FASTA)

anno  - genome annotation files (GFF/GTF/bed)

=item B<--path <dir>>

Generate a file named 'X.tsv' in the current directory(--out X.tsv), containing absolute 

paths of all files in the given path.

=item B<--out>

Set the output file name to be generated.

=item B<--anno>

Configuration file for displaying and editing annotation information.

=item B<--conf>

Display and modify the Configuration file.

=back

=head1 GenomeSyn2 Configuration File (total.conf) Help
-----------------------------------------------

=over 4

[genome_info] - Genome input settings (required)

gonomes_filetype: Type of genome files provided. (fasta, bed)

gonomes_list: Path to the genome information file or chromosome length file.

-----------------------------------

Example:

-----------------------------------

[genome_info]

gonomes_filetype = bed

gonomes_list = chr_length.info.tsv

-----------------------------------

[synteny_info] - Synteny block settings (required)

line_type: Style for connecting syntenic blocks. (curve, line)

synteny_list: File containing synteny information between genomes.

-----------------------------------

Example:

-----------------------------------

[synteny_info]

line_type = curve

synteny_list = synteny.info.tsv

-----------------------------------

[save_info] - Output figure settings (required)


figure_type: File format for saving figures. (svg, pdf, png)

savefig1 / savefig2: Output filenames for figure 1 and figure 2.

-----------------------------------

Example:

-----------------------------------

[save_info]

figure_type = pdf

savefig1 = GenomeSyn2.figure1.pdf

savefig2 = GenomeSyn2.figure2.pdf

-----------------------------------

[centromere_info] - Centromere visualization (optional)

centromere_list: File containing centromere positions.

-----------------------------------

Example: [centromere_info:yes] [centromere_info:no]

-----------------------------------

[centromere_info]

centromere_list = centromere.info.tsv

-----------------------------------

[telomere_info] - Telomere visualization (optional)

telomere_list: File containing telomere positions.

telomere_color: Color for telomere display.

opacity: Transparency of telomere display (0-100%).

-----------------------------------

Example: [telomere_info:yes] [telomere_info:no]

-----------------------------------

[telomere_info]

telomere_list = telomere.info.tsv

telomere_color = #441680

opacity = 100%

-----------------------------------

[show_region] - Specific region to highlight (optional)

region: Highlight a specific genomic region. (Format: genome_Name:ChrID:start-end)

gene_list: File listing genes in the highlighted region.

-----------------------------------------

Example:[show_region:yes] [show_region:no]

-----------------------------------------

[show_region]

region = R:Chr10_R:23,362,471-23,380,557

gene_list = gene.info.tsv

-----------------------------------------

[anno_info] - Annotation tracks (optional)

anno_number: Annotation track indices.

anno_name: Names for each annotation track.

anno_type: Plot type for each track. (rectangle, barplot, lineplot, heatmap)

anno_position: Position relative to chromosome plot. (top, bottom, middle)

anno_height: Height of each annotation track.

min_max_value: Minimum and maximum values for normalization or scaling. (normal, auto, min:max)

    normal: Displays data in the range 0 to the maximum value.

    auto: Normalizes data based on its actual minimum and maximum values. The smallest value is scaled to 0, and the largest value is scaled to the configured display height.

    min:max: User-defined display range. Values below min are set to min, and values above max are set to max.

anno_window: Window size for aggregating data (if applicable).

opacity: Transparency for each annotation track.

file_type: File type for annotation data. (bed, gff3)

filter_type: Filter applied to annotation.

anno_list: Files containing annotation data for each track.

anno_color: Color for each annotation track.

-----------------------------------------

Example: [anno_info:yes] [anno_info:no]

-----------------------------------------

[anno_info]

anno_number = [1,2,3,4,5]

anno_name = [PAV,SNP,GC Content,Gypsy,Gene density]

anno_color = ['#5FB6DE','#0000FF','#000000','#00FF00','#368F5C']

anno_type = [rectangle,barplot,lineplot,lineplot,heatmap]

anno_position = [top,top,top,bottom,middle]

anno_height = [5,5,5,5,5]

min_max_value = [normal,auto,0.4:0.5,normal,normal]

anno_window = [none,none,none,100000,100000,100000]

opacity = [50%,100%,100%,100%,100%]

file_type = [bed,bed,bed,gff3,gff3]

filter_type = [none,none,none,none,gene]

anno_list = [PAV.info.tsv,SNP.info.tsv,GC.info.tsv,Gypsy.info.tsv,gene.info.tsv]

-----------------------------------------

=back

=head1 optional ([telomere_info:<yes|no>],[centromere_info:<yes|no>],[anno_info:<yes|no>],[show_region:<yes|no>])

=over 4

=item B< > 

=item B< > 'yes' and 'no' serve as optional switches for enabling or disabling specific configuration blocks:

=item B< > 

=item B<    ** yes:> When set to 'yes' (or when the switch is omitted), the program parses and applies the parameters contained within the corresponding [...] block.

=item B< >

=item B<    ** no:> When set to 'no', the program skips that block and ignores all parameters defined within it.

=back

=cut

