#!/bin/bash
cp aggregateBinDepths.pl $PREFIX/bin
cp aggregateContigOverlapsByBin.pl $PREFIX/bin
cp contigOverlaps $PREFIX/bin
cp jgi_summarize_bam_contig_depths $PREFIX/bin
cp metabat $PREFIX/bin
cp metabat1 $PREFIX/bin
cp metabat2 $PREFIX/bin
cp runMetaBat.sh $PREFIX/bin

chmod +x $PREFIX/bin/aggregateBinDepths.pl
chmod +x $PREFIX/bin/aggregateContigOverlapsByBin.pl
chmod +x $PREFIX/bin/contigOverlaps
chmod +x $PREFIX/bin/jgi_summarize_bam_contig_depths
chmod +x $PREFIX/bin/metabat
chmod +x $PREFIX/bin/metabat1
chmod +x $PREFIX/bin/metabat2
chmod +x $PREFIX/bin/runMetaBat.sh

