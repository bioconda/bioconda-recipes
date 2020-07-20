#!/bin/bash
cd src
binaries="\
SpliceMap \
runSpliceMap \
sortsam \
nnrFilter \
neighborFilter \
uniqueJunctionFilter \
randomJunctionFilter \
wig2barwig \
colorJunction \
subseq \
findNovelJunctions \
statSpliceMap \
countsam \
amalgamateSAM \
precipitateSAM \
"
./install.sh $PREFIX/bin
for i in $binaries; do chmod +x $PREFIX/bin/$i; done