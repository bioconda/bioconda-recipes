#!/usr/bin/env bash
set -euo pipefail

turbo-picard --version
turbo-picard MarkDuplicates --help
turbo-picard SortSam --help
turbo-picard CleanSam --help
turbo-picard ViewSam --help

cat > input.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:1000
read-a	0	chr1	10	60	50M	*	0	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
read-b	0	chr1	10	60	50M	*	0	0	AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA	IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
SAM

turbo-picard MarkDuplicates \
  I=input.sam \
  O=marked.sam \
  M=metrics.txt \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s marked.sam
test -s metrics.txt
grep -q 'UNPAIRED_READ_DUPLICATES' metrics.txt
grep -q $'Unknown Library\t2\t0\t0\t0\t1\t0\t0\t0.5' metrics.txt

test ! -x "$(command -v picard || true)"

cat > unsorted.sam <<'SAM'
@HD	VN:1.6	SO:unsorted
@SQ	SN:chr1	LN:1000
read-c	0	chr1	90	60	10M	*	0	0	CCCCCCCCCC	FFFFFFFFFF
read-a	0	chr1	10	60	10M	*	0	0	AAAAAAAAAA	FFFFFFFFFF
read-b	0	chr1	50	60	10M	*	0	0	BBBBBBBBBB	FFFFFFFFFF
SAM

turbo-picard SortSam \
  I=unsorted.sam \
  O=coordinate.sam \
  SORT_ORDER=coordinate \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s coordinate.sam
grep -q $'@HD\tVN:1.6\tSO:coordinate' coordinate.sam
awk '!/^@/ { print $1 }' coordinate.sam | tr '\n' ' ' | grep -q '^read-a read-b read-c $'

turbo-picard SortSam \
  I=unsorted.sam \
  O=coordinate.bam \
  SORT_ORDER=coordinate \
  CREATE_INDEX=true \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s coordinate.bam
test -s coordinate.bai

turbo-picard BuildBamIndex \
  I=coordinate.bam \
  O=explicit.bai \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s explicit.bai

cat > dirty.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:1000
mapped	0	chr1	10	60	4M	*	0	0	ACGT	FFFF
unmapped	4	*	0	60	*	*	0	0	NNNN	!!!!
SAM

turbo-picard CleanSam \
  I=dirty.sam \
  O=cleaned.sam \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s cleaned.sam
grep -Fq $'unmapped\t4\t*\t0\t0\t*' cleaned.sam

turbo-picard ViewSam \
  I=coordinate.sam \
  O=view.sam \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s view.sam
grep -q '^read-a' view.sam

cat > replacement-header.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:2000
@CO	replacement header
SAM

turbo-picard ReplaceSamHeader \
  I=coordinate.sam \
  O=reheadered.sam \
  H=replacement-header.sam \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s reheadered.sam
grep -q $'@SQ\tSN:chr1\tLN:2000' reheadered.sam
grep -q '^read-a' reheadered.sam

turbo-picard SamToFastq \
  I=input.sam \
  FASTQ=reads.fastq \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s reads.fastq
grep -q '^@read-a$' reads.fastq

cat > fastq_filter.sam <<'SAM'
@HD	VN:1.6	SO:queryname
@SQ	SN:chr1	LN:1000
pf	4	*	0	0	*	*	0	0	AAAA	FFFF
nonpf	516	*	0	0	*	*	0	0	CCCC	FFFF
secondary	260	*	0	0	*	*	0	0	GGGG	FFFF
SAM

turbo-picard SamToFastq \
  I=fastq_filter.sam \
  FASTQ=filtered.fastq \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q '^@pf$' filtered.fastq
! grep -q '^@nonpf$' filtered.fastq
! grep -q '^@secondary$' filtered.fastq

cat > fastqtosam-r1.fastq <<'FQ'
@read1
ACGT
+
FFFF
FQ
cat > fastqtosam-r2.fastq <<'FQ'
@read1
TTTT
+
IIII
FQ

turbo-picard FastqToSam \
  F1=fastqtosam-r1.fastq \
  F2=fastqtosam-r2.fastq \
  O=fastqtosam.sam \
  SM=sample \
  RG=rg1 \
  QUALITY_FORMAT=Standard \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s fastqtosam.sam
grep -q $'@RG\tID:rg1\tSM:sample' fastqtosam.sam
grep -Fq $'read1\t77\t*\t0\t0\t*\t*\t0\t0\tACGT\tFFFF\tRG:Z:rg1' fastqtosam.sam
grep -Fq $'read1\t141\t*\t0\t0\t*\t*\t0\t0\tTTTT\tIIII\tRG:Z:rg1' fastqtosam.sam

turbo-picard AddOrReplaceReadGroups \
  I=input.sam \
  O=readgroups.sam \
  RGID=new \
  RGLB=library-a \
  RGPL=ILLUMINA \
  RGPU=unit-a \
  RGSM=sample-a \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s readgroups.sam
grep -q $'@RG\tID:new\tLB:library-a\tPL:ILLUMINA\tSM:sample-a\tPU:unit-a' readgroups.sam
grep -q $'RG:Z:new' readgroups.sam

turbo-picard MergeSamFiles \
  I=coordinate.sam \
  I=readgroups.sam \
  O=merged_samfiles.sam \
  SORT_ORDER=coordinate \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s merged_samfiles.sam
grep -q '^read-a' merged_samfiles.sam

turbo-picard CollectAlignmentSummaryMetrics \
  I=input.sam \
  O=alignment_metrics.txt \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s alignment_metrics.txt
grep -q 'picard.analysis.AlignmentSummaryMetrics' alignment_metrics.txt
grep -q '^UNPAIRED' alignment_metrics.txt

turbo-picard CollectQualityYieldMetrics \
  I=input.sam \
  O=quality_yield_metrics.txt \
  STOP_AFTER=1 \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s quality_yield_metrics.txt
grep -q 'CollectQualityYieldMetrics' quality_yield_metrics.txt

turbo-picard CollectBaseDistributionByCycle \
  I=input.sam \
  O=base_distribution_by_cycle.txt \
  CHART=base_distribution_by_cycle.pdf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s base_distribution_by_cycle.txt
test -s base_distribution_by_cycle.pdf
grep -q $'READ_END\tCYCLE\tPCT_A' base_distribution_by_cycle.txt

turbo-picard QualityScoreDistribution \
  I=input.sam \
  O=quality_score_distribution.txt \
  CHART=quality_score_distribution.pdf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s quality_score_distribution.txt
test -s quality_score_distribution.pdf
grep -q $'QUALITY\tCOUNT_OF_Q' quality_score_distribution.txt

turbo-picard MeanQualityByCycle \
  I=input.sam \
  O=mean_quality_by_cycle.txt \
  CHART=mean_quality_by_cycle.pdf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s mean_quality_by_cycle.txt
test -s mean_quality_by_cycle.pdf
grep -q $'CYCLE\tMEAN_QUALITY' mean_quality_by_cycle.txt

cat > gc_ref.fa <<'FA'
>low
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
>high
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
FA
cat > gc_input.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:low	LN:40
@SQ	SN:high	LN:40
low1	0	low	1	60	20M	*	0	0	AAAAAAAAAAAAAAAAAAAA	FFFFFFFFFFFFFFFFFFFF
high1	0	high	1	60	20M	*	0	0	CCCCCCCCCCCCCCCCCCCC	FFFFFFFFFFFFFFFFFFFF
SAM

turbo-picard CollectGcBiasMetrics \
  I=gc_input.sam \
  O=gc_bias.detail.txt \
  S=gc_bias.summary.txt \
  CHART=gc_bias.pdf \
  R=gc_ref.fa \
  SCAN_WINDOW_SIZE=20 \
  MINIMUM_GENOME_FRACTION=0 \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s gc_bias.detail.txt
test -s gc_bias.summary.txt
test -s gc_bias.pdf
grep -q 'picard.analysis.GcBiasDetailMetrics' gc_bias.detail.txt
grep -q 'picard.analysis.GcBiasSummaryMetrics' gc_bias.summary.txt

cat > paired.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:1000
pair1	99	chr1	10	60	4M	=	30	24	ACGT	FFFF
pair1	147	chr1	30	60	4M	=	10	-24	TGCA	FFFF
pair2	99	chr1	100	60	4M	=	130	34	AAAA	FFFF
pair2	147	chr1	130	60	4M	=	100	-34	TTTT	FFFF
dup1	1123	chr1	200	60	4M	=	240	44	CCCC	FFFF
dup1	1171	chr1	240	60	4M	=	200	-44	GGGG	FFFF
SAM

turbo-picard CollectInsertSizeMetrics \
  I=paired.sam \
  O=insert_size_metrics.txt \
  H=insert_size_histogram.pdf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s insert_size_metrics.txt
test -s insert_size_histogram.pdf
grep -q 'picard.analysis.InsertSizeMetrics' insert_size_metrics.txt
grep -q $'insert_size\tAll_Reads.fr_count' insert_size_metrics.txt

turbo-picard CollectInsertSizeMetrics \
  I=paired.sam \
  O=insert_size_metrics_with_duplicates.txt \
  H=insert_size_histogram_with_duplicates.pdf \
  INCLUDE_DUPLICATES=true \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q $'44\t1' insert_size_metrics_with_duplicates.txt

turbo-picard CollectMultipleMetrics \
  I=paired.sam \
  O=multiple \
  PROGRAM=null \
  PROGRAM=CollectInsertSizeMetrics \
  PROGRAM=CollectBaseDistributionByCycle \
  PROGRAM=QualityScoreDistribution \
  PROGRAM=MeanQualityByCycle \
  PROGRAM=CollectQualityYieldMetrics \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s multiple.insert_size_metrics
test -s multiple.insert_size_histogram.pdf
test -s multiple.base_distribution_by_cycle_metrics
test -s multiple.base_distribution_by_cycle.pdf
test -s multiple.quality_distribution_metrics
test -s multiple.quality_distribution.pdf
test -s multiple.quality_by_cycle_metrics
test -s multiple.quality_by_cycle.pdf
test -s multiple.quality_yield_metrics

turbo-picard CollectMultipleMetrics \
  I=gc_input.sam \
  O=multiple_gc \
  R=gc_ref.fa \
  PROGRAM=null \
  PROGRAM=CollectGcBiasMetrics \
  EXTRA_ARGUMENT=CollectGcBiasMetrics::SCAN_WINDOW_SIZE=20 \
  EXTRA_ARGUMENT=CollectGcBiasMetrics::MINIMUM_GENOME_FRACTION=0 \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s multiple_gc.gc_bias.detail_metrics
test -s multiple_gc.gc_bias.summary_metrics
test -s multiple_gc.gc_bias.pdf

turbo-picard CollectMultipleMetrics \
  I=paired.sam \
  O=multiple_default \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s multiple_default.alignment_summary_metrics
test -s multiple_default.base_distribution_by_cycle_metrics
test -s multiple_default.insert_size_metrics
test -s multiple_default.quality_by_cycle_metrics
test -s multiple_default.quality_distribution_metrics
test ! -e multiple_default.quality_yield_metrics

cat > fixmate.sam <<'SAM'
@HD	VN:1.6	SO:queryname
@SQ	SN:chr1	LN:1000
pair1	99	chr1	10	60	4M	*	0	0	ACGT	FFFF
pair1	147	chr1	30	60	4M	*	0	0	TGCA	FFFF
SAM

turbo-picard FixMateInformation \
  I=fixmate.sam \
  O=fixed_mate.sam \
  ASSUME_SORTED=true \
  SORT_ORDER=queryname \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s fixed_mate.sam
grep -q $'pair1\t99\tchr1\t10\t60\t4M\t=\t30\t24' fixed_mate.sam
grep -q $'MC:Z:4M\tMQ:i:60' fixed_mate.sam

cat > aligned.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:1000
@RG	ID:rg1	SM:sample	LB:lib	PL:ILLUMINA
read1	1024	chr1	10	60	4M	*	0	0	ACGT	!!!!	RG:Z:rg1	OQ:Z:FFFF	NM:i:0	MD:Z:4	PG:Z:align
SAM

turbo-picard RevertSam \
  I=aligned.sam \
  O=reverted.sam \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s reverted.sam
grep -Fq $'read1\t4\t*\t0\t0\t*\t*\t0\t0\tACGT\tFFFF\tRG:Z:rg1' reverted.sam

cat > reference.fa <<'FASTA'
>chr1
ACGTACGT
FASTA

turbo-picard CreateSequenceDictionary \
  R=reference.fa \
  O=reference.dict \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s reference.dict
grep -q $'@SQ\tSN:chr1\tLN:8\tM5:cc0af3a4fedb18378b4b57b98068e69f' reference.dict

cat > needs_tags.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:8
read1	0	chr1	1	60	4M	*	0	0	ACGA	FFFF
SAM

turbo-picard SetNmMdAndUqTags \
  I=needs_tags.sam \
  O=tagged.sam \
  R=reference.fa \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s tagged.sam
grep -q $'MD:Z:3T0\tNM:i:1\tUQ:i:37' tagged.sam

cat > wgs.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:8
read1	0	chr1	1	60	4M	*	0	0	ACGT	FFFF
read2	0	chr1	5	60	4M	*	0	0	ACGT	FFFF
SAM

turbo-picard CollectWgsMetrics \
  I=wgs.sam \
  O=wgs_metrics.txt \
  R=reference.fa \
  COUNT_UNPAIRED=true \
  SAMPLE_SIZE=0 \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q $'GENOME_TERRITORY\tMEAN_COVERAGE' wgs_metrics.txt
grep -q $'8\t1\t0\t1\t0\t0\t0\t0\t0\t0\t0\t0\t0\t1' wgs_metrics.txt

cat > wgs_targets.interval_list <<'INTERVALS'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:8
chr1	3	6	+	target
INTERVALS

turbo-picard CollectWgsMetrics \
  I=wgs.sam \
  O=wgs_interval_metrics.txt \
  R=reference.fa \
  INTERVALS=wgs_targets.interval_list \
  COUNT_UNPAIRED=true \
  SAMPLE_SIZE=0 \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q $'4\t1\t0\t1\t0\t0\t0\t0\t0\t0\t0\t0\t0\t1' wgs_interval_metrics.txt

cat > valid_for_validation.sam <<'SAM'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:8
@RG	ID:rg1	SM:sample	PL:ILLUMINA
read1	0	chr1	1	60	4M	*	0	0	ACGT	FFFF	RG:Z:rg1	NM:i:0
SAM

turbo-picard ValidateSamFile \
  I=valid_for_validation.sam \
  O=validation_summary.txt \
  MODE=SUMMARY \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q 'No errors found' validation_summary.txt

cat > identity.chain <<'CHAIN'
chain 100 chr1 8 + 0 8 chr1 8 + 0 8 1
8
CHAIN

cat > liftover_input.vcf <<'VCF'
##fileformat=VCFv4.2
##contig=<ID=chr1,length=8>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
chr1	2	.	C	G	.	PASS	.
VCF

turbo-picard LiftoverVcf \
  I=liftover_input.vcf \
  O=lifted.vcf \
  CHAIN=identity.chain \
  REJECT=lifted.reject.vcf \
  R=reference.fa \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

grep -q $'chr1\t2\t.\tC\tG\t.\tPASS\t.' lifted.vcf
test -s lifted.reject.vcf

turbo-picard NormalizeFasta \
  I=reference.fa \
  O=normalized.fa \
  LINE_LENGTH=4

test -s normalized.fa
grep -q '^ACGT$' normalized.fa

cat > targets.bed <<'BED'
chr1	0	4	target	0	+
BED

turbo-picard BedToIntervalList \
  I=targets.bed \
  O=targets.interval_list \
  SD=reference.dict \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s targets.interval_list
grep -q $'chr1\t1\t4\t+\ttarget' targets.interval_list

cat > extra.interval_list <<'EOF'
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:8
chr1	4	8	+	extra
EOF

turbo-picard IntervalListTools \
  I=targets.interval_list \
  I=extra.interval_list \
  O=merged.interval_list \
  ACTION=CONCAT \
  SORT=true \
  UNIQUE=true \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s merged.interval_list
grep -q $'chr1\t1\t8\t+\ttarget|extra' merged.interval_list

cat > input.vcf <<'VCF'
##fileformat=VCFv4.2
##contig=<ID=old,length=10>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
chr1	2	.	A	C	.	PASS	.
VCF

turbo-picard UpdateVcfSequenceDictionary \
  I=input.vcf \
  O=updated.vcf \
  SD=reference.dict \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s updated.vcf
grep -q '##contig=<ID=chr1,length=8' updated.vcf
grep -q $'chr1\t2\t.\tA\tC\t.\tPASS\t.' updated.vcf

cat > shard2.vcf <<'VCF'
##fileformat=VCFv4.2
##contig=<ID=chr1,length=8>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
chr1	7	.	G	T	.	PASS	.
VCF

turbo-picard GatherVcfs \
  I=updated.vcf \
  I=shard2.vcf \
  O=gathered.vcf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s gathered.vcf
grep -q $'chr1\t7\t.\tG\tT\t.\tPASS\t.' gathered.vcf

turbo-picard SortVcf \
  I=gathered.vcf \
  O=sorted.vcf \
  SD=reference.dict \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s sorted.vcf
awk '!/^#/ { print $2 }' sorted.vcf | tr '\n' ' ' | grep -q '^2 7 $'

cat > merge1.vcf <<'VCF'
##fileformat=VCFv4.2
##contig=<ID=chr1,length=8>
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
chr1	2	.	A	C	.	PASS	.
VCF

turbo-picard MergeVcfs \
  I=shard2.vcf \
  I=merge1.vcf \
  O=merged.vcf \
  VALIDATION_STRINGENCY=SILENT \
  QUIET=true

test -s merged.vcf
awk '!/^#/ { print $2 }' merged.vcf | tr '\n' ' ' | grep -q '^2 7 $'
