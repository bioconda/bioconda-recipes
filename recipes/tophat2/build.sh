#!/bin/bash

mkdir -p $PREFIX/bin

binaries="\
bam2fastx \
bam_merge \
bed_to_juncs \
contig_to_chr_coords \
fix_map_ordering \
gtf_juncs \
gtf_to_fasta \
juncs_db
long_spanning_reads \
map2gtf \
prep_reads \
sam_juncs \
samtools_0.1.18 \
segment_juncs \
sra_to_solid \
tophat \
tophat2 \
tophat-fusion-post \
tophat_reports \
"
directories="sortedcontainers intervaltree"
pythonfiles="tophat bed_to_juncs contig_to_chr_coords sra_to_solid tophat-fusion-post"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
for d in $directories; do cp -r $d $PREFIX/bin; done
