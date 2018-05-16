#!/bin/bash

mkdir -p $PREFIX/bin

make

binaries="\
CompressSAM \
DecompressSAM \
CompressQual \
DecompressQual \
CompressSeq \
DecompressSeq \
GetIntervalSeq \
GetIntervalSeqSample \
CountReadsSample \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done