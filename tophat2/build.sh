#!/bin/bash

mkdir -p $PREFIX/bin

if [ $PY3K -eq 1 ]
then
    2to3 --write tophat bed_to_juncs contig_to_chr_coords sra_to_solid tophat-fusion-post
fi

cp bam2fastx $PREFIX/bin
cp bam_merge $PREFIX/bin
cp bed_to_juncs $PREFIX/bin
cp contig_to_chr_coords $PREFIX/bin
cp fix_map_ordering $PREFIX/bin
cp gtf_juncs $PREFIX/bin
cp gtf_to_fasta $PREFIX/bin
cp -r intervaltree $PREFIX/bin
cp juncs_db $PREFIX/bin
cp long_spanning_reads $PREFIX/bin
cp map2gtf $PREFIX/bin
cp prep_reads $PREFIX/bin
cp sam_juncs $PREFIX/bin
cp samtools_0.1.18 $PREFIX/bin
cp segment_juncs $PREFIX/bin
cp -r sortedcontainers $PREFIX/bin
cp sra_to_solid $PREFIX/bin
cp tophat $PREFIX/bin
cp tophat2 $PREFIX/bin
cp tophat-fusion-post $PREFIX/bin
cp tophat_reports $PREFIX/bin

