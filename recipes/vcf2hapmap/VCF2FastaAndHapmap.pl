
#!/usr/bin/perl

use strict;
use Getopt::Long;

my $usage = qq~Usage:$0 <args> [<opts>]

where <args> are:

    -v, --vcf          <VCF input>
    -o, --out          <Output basename>
      
<opts> are:

    -r, --reference    <Reference fasta file>
    -g, --gff          <GFF input file to create alignments of genes>
~;
$usage .= "\n";

my ($input,$out,$reference,$gff);



GetOptions(
	"vcf=s"          => \$input,
	"out=s"          => \$out,
	"reference=s"    => \$reference,
	"gff=s"          => \$gff
);


die $usage
  if ( !$input || !$out);
 
if ($gff && !$reference)
{
	die "You must provide a Fasta reference file when providing GFF annotation\n";
}

 
my %ref_sequences;  
if ($reference)
{
	my $id;
	my $sequence = "";
	open(my $R,$reference) or die "cannot open file: $reference";
	while(<$R>)
	{
		my $line =$_;
		$line =~s/\n//g;
		$line =~s/\r//g;
		if ($line =~ />([^\s]+)/){
			$ref_sequences{$id} = $sequence;
			$id=$1;$sequence="";
		}
		else
		{
			$sequence .= $line;
		}
	}
	close($R);
	$ref_sequences{$id} = $sequence;
}


my %chr_of_gene;
my %ann;
if ($gff)
{
	open(my $G,$gff) or die "cannot open file: $gff";
	while(<$G>)
	{
		my $line =$_;
		$line =~s/\n//g;
		$line =~s/\r//g;
		my @i = split(/\t/,$line);
		my $chr = $i[0];
		my $feature = $i[2];
		my $strand = $i[6];
		my $start = $i[3];
		my $stop = $i[4];
		my $inf = $i[8];
		if ($feature eq 'gene')
		{
			 if ($inf =~/Name=([\w\-\.]+)[;\s]*/){$inf = $1;}
			$ann{$inf}{"start"}=$start;
			$ann{$inf}{"stop"}=$stop;
			$ann{$inf}{"strand"}=$strand;
			$chr_of_gene{$inf} = $chr;
		}
	}
	close($G);
}



my %IUPAC =
(
        '[A/G]'=> "R",
        '[G/A]'=> "R",
        '[C/T]'=> "Y",
        '[T/C]'=> "Y",
        '[T/G]'=> "K",
        '[G/T]'=> "K",
        '[C/G]'=> "S",
        '[G/C]'=> "S",
        '[A/T]'=> "W",
        '[T/A]'=> "W",
        '[A/C]'=> "M",
        '[C/A]'=> "M",
        '[C/A/T]'=> "H",
        '[A/T/C]'=> "H",
        '[A/C/T]'=> "H",
        '[C/T/A]'=> "H",
        '[T/C/A]'=> "H",
        '[T/A/C]'=> "H",
        '[C/A/G]'=> "V",
        '[A/G/C]'=> "V",
        '[A/C/G]'=> "V",
        '[C/G/A]'=> "V",
        '[G/C/A]'=> "V",
        '[G/A/C]'=> "V",
        '[C/T/G]'=> "B",
        '[T/G/C]'=> "B",
        '[T/C/G]'=> "B",
        '[C/G/T]'=> "B",
        '[G/C/T]'=> "B",
        '[G/T/C]'=> "B",
        '[T/A/G]'=> "D",
        '[A/G/T]'=> "D",
        '[A/T/G]'=> "D",
        '[T/G/A]'=> "D",
        '[G/T/A]'=> "D",
        '[G/A/T]'=> "D",
);

my %snps_of_gene;
my %snps_of_gene2;
my %indiv_order;
my $indiv_list;
my %genotyping_infos;
my $num_line = 0;
my $genename_rank_in_snpeff = 4;

my $find_annotations = `grep -c 'EFF=' $input`;

open(my $HAPMAP,">$out.hapmap");
print $HAPMAP "rs#	alleles	chrom	pos	gene	feature	effect	codon_change	amino_acid_change	MAF	missing_data";
open(my $VCF,$input);
while(<$VCF>)
{
	my $line = $_;
	chomp($line);
	my @infos = split(/\t/,$line);
	
	if (/^##INFO=\<ID=EFF/ && /Amino_Acid_length \| Gene_Name \| Transcript_BioType \| Gene_Coding/)
	{
		$genename_rank_in_snpeff = 8;
	}

	if (scalar @infos > 9)
	{
		if (/#CHROM/)
		{
			for (my $j=9;$j<=$#infos;$j++)
			{
				my $individu = $infos[$j];
				$indiv_list .= "	$individu";
				$indiv_order{$j} = $individu;
			}
			print $HAPMAP "$indiv_list\n";
		}
		elsif (!/^#/)
		{
			$num_line++;

			my $chromosome = $infos[0];
			my $chromosome_position = $infos[1];
			my $ref_allele = $infos[3];
			my $alt_allele = $infos[4];
                    	
			if ($ref_allele =~/\w\w+/)
			{
				$ref_allele = "A";
				$alt_allele = "T";
			}
			elsif ($alt_allele =~/\w\w+/)
			{
				$ref_allele = "T";
				$alt_allele = "A";
			}
			
			my $info = $infos[7];
			my $is_in_exon = "#";
			my $is_synonyme = "#";
			my $gene;
			if ($find_annotations > 1)
			{
				$gene = "intergenic";
			}
			else
			{
				$gene = $chromosome;
			}
			my $modif_codon = "#";
			my $modif_aa = "#";
			my $geneposition;
			if ($info =~/EFF=(.*)/)
			{
					my @annotations = split(",",$1);
					foreach my $annotation(@annotations)
					{
						my ($syn, $additional) = split(/\(/,$annotation);

						if ($syn =~/STREAM/){next;}

						$is_in_exon = "exon";
						if ($syn =~/UTR/)
						{
							$is_in_exon = $syn;
						}
						else
						{
							$is_synonyme = $syn;
						}
						my @infos_additional = split(/\|/,$additional);
						$gene = $infos_additional[$genename_rank_in_snpeff];
						$modif_codon = $infos_additional[2];
						$modif_aa = $infos_additional[3];
						
						if ($syn =~/INTERGENIC/)
						{
							$is_synonyme = "#";
							$gene = "intergenic";
							$is_in_exon = "#";
						}
						elsif ($syn =~/SYNONYM/)
						{
							$is_in_exon = "exon";
						}
						elsif ($syn =~/INTRON/ or $syn =~/SPLICE_SITE_DONOR/)
						{
							$is_in_exon = "intron";
							$is_synonyme = "#";
						}
						
						
						if ($modif_aa =~/(\w)(\d+)$/)
						{
							$modif_aa = "$1/$1";
						}
						elsif ($modif_aa =~/(\w)(\d+)(\w)/)
						{
							$modif_aa = "$1/$3";
						}
						if ($infos_additional[8] =~/Exon/)
						{
							$is_in_exon = "exon";
						}
						
						if (!$modif_aa){$modif_aa="#";}
						if (!$modif_codon){$modif_codon="#";}
					}
			}
			$gene =~s/\.\d//g;
			if ($ann{$gene}{"start"})
			{
				my $strand = $ann{$gene}{"strand"};
				if ($strand eq '-')
				{
					$geneposition = $ann{$gene}{"stop"} - $chromosome_position;
				}
				else
				{
					$geneposition = $chromosome_position - $ann{$gene}{"start"};
				}
			}
			#if ($info =~/GenePos=(\d+);/)
			#{
			#	$geneposition = $1;
			#}
			my $ratio_missing_data;
			my $snp_frequency;
			my $genotyping = "";
			
			if (2 > 1)
			{
				
				$genotyping_infos{"ref"} = "$ref_allele$ref_allele";
				
				my %alleles_found;
				my $nb_readable_ind = 0;
				for (my $i = 9;$i <= $#infos;$i++)
				{
					my $dnasample = $indiv_order{$i};
					my @infos_alleles = split(":",$infos[$i]);
					my $genotype = $infos_alleles[0];
					$genotype =~s/0/$ref_allele/g;

					if ($alt_allele =~/,/)
					{
						my @alt_alleles = split(",",$alt_allele);
						my $num_all = 1;
						foreach my $alt_al(@alt_alleles)
						{
							$genotype =~s/$num_all/$alt_al/g;
							$num_all++;
						}
					}
					else
					{
						$genotype =~s/1/$alt_allele/g;
					}
					if ($genotype eq '.'){$genotype = "./.";}
					$genotype =~s/\./N/g;
					if ($genotype !~/N\/N/)
					{
						$nb_readable_ind++;
					}
					my @alleles;
					if ($genotype =~/\//)
					{
						@alleles = split(/\//,$genotype);
					}
					else
					{
						@alleles = split(/\|/,$genotype);
					}
					$genotyping .= join("",@alleles) . "	";
					$genotyping_infos{$dnasample} = join("",@alleles);
					
					foreach my $al(@alleles)
					{
						if ($al ne 'N'){$alleles_found{$al}++;}
					}	
				}
				chop($genotyping);
				
				$snp_frequency = 0;
					
				my $max = 0;
				my $min = 10000000;
				my $total = 0;
				foreach my $al(keys(%alleles_found))
				{
					my $nb = $alleles_found{$al};
					$total+= $nb;
					if ($nb > $max)
					{
						$max = $nb;
					}
					if ($nb < $min)
					{
						$min = $nb;
					}
				}
				if ($total > 0)
				{
					$snp_frequency = sprintf("%.1f",($min/$total)*100);
				}
				
				$ratio_missing_data = 100 - ($nb_readable_ind / ($#infos - 8)) * 100;
				$ratio_missing_data = sprintf("%.1f",$ratio_missing_data);

				foreach my $dna(keys(%genotyping_infos))
				{
					$snps_of_gene{$gene}{$geneposition}{$dna} = $genotyping_infos{$dna};
				}
			}
			my $snp_type = "[$ref_allele/$alt_allele]";
			$snps_of_gene2{$chromosome}{$chromosome_position} = $snp_type;
			#print $HAPMAP "$chromosome:$chromosome_position\t$snp_type\t$chromosome\t$chromosome_position\t$gene:$geneposition\t$is_in_exon\t$is_synonyme\t$modif_codon\t$modif_aa\t$snp_frequency%\t$nb_readable_ind\t$genotyping\n";
			print $HAPMAP "$chromosome:$chromosome_position\t$ref_allele/$alt_allele\t$chromosome\t$chromosome_position\t$gene:$geneposition\t$is_in_exon\t$is_synonyme\t$modif_codon\t$modif_aa\t$snp_frequency%\t$ratio_missing_data%\t$genotyping\n";
		}
	}
}
close($VCF);
close($HAPMAP);


if (!$reference){exit;}

#################################################################
# generate flanking sequences for Illumina VeraCode technology
#################################################################
open(my $FLANKING,">$out.flanking.txt");
foreach my $seq(keys(%ref_sequences))
{
                        if ($snps_of_gene2{$seq})
                        {
                                my $refhash = $snps_of_gene2{$seq};
                                my %hashreal = %$refhash;

                                # create consensus
                                my $refseq = $ref_sequences{$seq};
                                my $consensus = "";
                                my $previous = 0;
                                foreach my $pos(sort {$a<=>$b} keys(%hashreal))
                                {
                                        my $length = $pos - $previous - 1;
                                        $consensus .= substr($refseq,$previous,$length);
                                        my $iupac_code = $IUPAC{$snps_of_gene2{$seq}{$pos}};
                                        $consensus .= $iupac_code;
                                        $previous = $pos;
                                }
                                my $length = length($refseq) - $previous;
                                $consensus .= substr($refseq,$previous,$length);

                                foreach my $pos(sort {$a<=>$b} keys(%hashreal))
                                {
                                        my $snp_name = "$seq-$pos";
                                        my $flanking_length = 60;
                                        my $length = $flanking_length;
                                        my $start = $pos - $flanking_length - 1;
                                        if ($pos <= $flanking_length)
                                        {
                                                $length = $pos - 1;
                                                $start = 0;
                                        }
                                        my $sequence = substr($consensus,$start,$length);
				
                                        $sequence .= $snps_of_gene2{$seq}{$pos};
                                        $sequence .= substr($consensus,$pos,$flanking_length);
                                        print $FLANKING "$snp_name,$sequence,0,0,0,Project_name,0,diploid,Other,Forward\n";
                                }
                        }
	}

	close($FLANKING);

	if (!$gff){exit;}

	my @individuals_list = split(/\t/,$indiv_list);
	if ((scalar @individuals_list * scalar keys(%snps_of_gene)) > 800000)
	{
		print "Sorry, too many sequences to manage ...\n";
		exit;
	}

	open(my $ALIGN_EGGLIB,">$out.gene_alignment.fas");
	my %alignments_ind;
	foreach my $seq(keys(%snps_of_gene))
	{
		if ($snps_of_gene{$seq})
		{
			my $refhash = $snps_of_gene{$seq};
			my %hashreal = %$refhash;

			# get flanking sequences
			my %flanking5;
			my $start = $ann{$seq}{"start"};
			my $stop = $ann{$seq}{"stop"};
			my $strand = $ann{$seq}{"strand"};
			my $genelength = $stop - $start+1;
			my $chr = $chr_of_gene{$seq};
		my $refseq = substr($ref_sequences{$chr},$start-1,$genelength);
		if ($strand eq '-')
		{
			$refseq =~ tr /atcgATCG/tagcTAGC/; $refseq = reverse($refseq);
		}	
		#print "$seq $chr $start $stop $refseq \n";
		my $previous = 0;
		foreach my $pos(sort {$a<=>$b} keys(%hashreal))
		{
			my $length = $pos - $previous - 1;
			$flanking5{$pos} = substr($refseq,$previous,$length);
			$previous = $pos;
		}
		my $length = length($refseq) - $previous;
		my $flanking3 = substr($refseq,$previous,$length);
		foreach my $ind(@individuals_list)
		{
			my $nb_missing_data_for_this_individual = 0;
			if ($ind)
			{
                                                my $alignment_for_ind = "";
                                                my $seq_without_underscore = $seq;
                                                $seq_without_underscore =~s/_//g;
                                                $alignment_for_ind .= ">$seq_without_underscore" . "_$ind" . "_1\n";
                                                foreach my $pos(sort {$a<=>$b} keys(%hashreal))
                                                {
                                                        $alignment_for_ind .= $flanking5{$pos};
                                                        my $geno = $snps_of_gene{$seq}{$pos}{$ind};
                                                        $geno =~s/N/?/g;
                                                        if ($geno =~/\?/){$nb_missing_data_for_this_individual++;}
                                                        my @alleles = split("",$geno);
                                                        $alignment_for_ind .= $alleles[0];
                                                        if ($alleles[0] eq $alleles[1])
                                                        {
                                                                $alignments_ind{$ind} .= $alleles[1];
                                                        }
                                                        else
                                                        {
                                                                my $snp_type = "[" . $alleles[0] . "/" . $alleles[1] . "]";
                                                                $alignments_ind{$ind} .= $IUPAC{$snp_type};
                                                        }
                                                }
                                                $alignment_for_ind .= $flanking3;
						$alignment_for_ind .= "\n";
			
			
                                                $alignment_for_ind .= ">$seq_without_underscore" . "_$ind" . "_2\n";
                                                foreach my $pos(sort {$a<=>$b} keys(%hashreal))
                                                {
                                                        $alignment_for_ind .= $flanking5{$pos};
                                                        my $geno = $snps_of_gene{$seq}{$pos}{$ind};
                                                        $geno =~s/N/?/g;
                                                        my @alleles = split("",$geno);
                                                        $alignment_for_ind .= $alleles[1];
                                                }
                                                $alignment_for_ind .= $flanking3;
						$alignment_for_ind .= "\n";
                                                if (keys(%hashreal) != $nb_missing_data_for_this_individual)
                                                {
                                                        print $ALIGN_EGGLIB $alignment_for_ind;
                                                }
			}
		}
	}
}
close($ALIGN_EGGLIB);



