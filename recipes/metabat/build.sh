mkdir -p $PREFIX/MetaBAT/
mkdir -p $PREFIX/bin/

cp ./* $PREFIX/MetaBAT

ln -s $PREFIX/MetaBAT/aggregateBinDepths.pl            $PREFIX/bin/
ln -s $PREFIX/MetaBAT/aggregateContigOverlapsByBin.pl  $PREFIX/bin/
ln -s $PREFIX/MetaBAT/contigOverlaps                   $PREFIX/bin/
ln -s $PREFIX/MetaBAT/jgi_summarize_bam_contig_depths  $PREFIX/bin/
ln -s $PREFIX/MetaBAT/metabat                          $PREFIX/bin/
ln -s $PREFIX/MetaBAT/runMetaBat.sh                    $PREFIX/bin/
