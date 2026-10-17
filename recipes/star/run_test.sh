#!/bin/bash
set -euo pipefail

# Align a few reads to a tiny synthetic genome and check STAR actually reads and maps them.
# One run covers --readFilesCommand, --twopassMode (inputs re-opened for pass 2) and
# --quantMode with a GTF; builds that exit 0 but report 0 input reads fail here.

# 2 kb deterministic pseudo-random genome (LCG), plus 3 reads of 50 bp cut from it
awk 'BEGIN { x = 1; s = "";
             for (i = 0; i < 2000; i++) { x = (1103515245 * x + 12345) % 2147483648; s = s substr("ACGT", int(x / 65536) % 4 + 1, 1) }
             print ">chr1\n" s > "ref.fa";
             q = "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII";
             for (r = 1; r <= 3; r++) print "@r" r "\n" substr(s, 300 * r, 50) "\n+\n" q > "reads.fq" }'
printf 'chr1\ttest\texon\t101\t1900\t.\t+\t.\tgene_id "g1"; transcript_id "t1";\n' > ann.gtf

mkdir genome
STAR --runMode genomeGenerate --runThreadN 1 --genomeDir genome --genomeFastaFiles ref.fa \
     --sjdbGTFfile ann.gtf --sjdbOverhang 49 --genomeSAindexNbases 4 --outFileNamePrefix gen_

STAR --runThreadN 2 --genomeDir genome --readFilesIn reads.fq --readFilesCommand cat \
     --twopassMode Basic --quantMode TranscriptomeSAM --outSAMtype SAM --outFileNamePrefix out_

input=$(awk -F'|' '/Number of input reads/ {gsub(/[ \t]/, "", $2); print $2}' out_Log.final.out)
unique=$(awk -F'|' '/Uniquely mapped reads number/ {gsub(/[ \t]/, "", $2); print $2}' out_Log.final.out)
echo "input reads: ${input}, uniquely mapped: ${unique}"
test "${input}" = 3
test "${unique}" = 3
test -s out_Aligned.toTranscriptome.out.bam
