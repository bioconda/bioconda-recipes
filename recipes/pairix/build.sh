#!/bin/bash

# Install both the pairix binaries and the Python extension module
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
cp bin/pairix $PREFIX/bin/pairix
cp bin/pairs_merger $PREFIX/bin/pairs_merger
cp bin/streamer_1d $PREFIX/bin/streamer_1d
cp util/column_remover.pl $PREFIX/bin/column_remover.pl
cp util/duplicate_header_remover.pl $PREFIX/bin/duplicate_header_remover.pl
cp util/fragment_4dnpairs.pl $PREFIX/bin/fragment_4dnpairs.pl
cp util/juicer_shortform2pairs.pl $PREFIX/bin/juicer_shortform2pairs.pl
cp util/merge-pairs.sh $PREFIX/bin/merge-pairs.sh
cp util/merged_nodup2pairs.pl $PREFIX/bin/merged_nodup2pairs.pl
cp util/old_merged_nodup2pairs.pl $PREFIX/bin/old_merged_nodup2pairs.pl
cp util/process_merged_nodup.sh $PREFIX/bin/process_merged_nodup.sh
cp util/process_old_merged_nodup.sh $PREFIX/bin/process_old_merged_nodup.sh
cp util/bam2pairs/bam2pairs $PREFIX/bin/bam2pairs
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
