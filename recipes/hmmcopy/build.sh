#!/bin/bash

# Source archive contains some macOS junk files,
# which prevent hoisting the HMMcopy on Linux only.
cd HMMcopy || true
cmake .
make
mkdir -p $PREFIX/bin
cp util/bigwig/bigWigInfo $PREFIX/bin/bigWigInfo
cp util/bigwig/bigWigSummary $PREFIX/bin/bigWigSummary
cp util/bigwig/bigWigToBedGraph $PREFIX/bin/bigWigToBedGraph
cp util/bigwig/bigWigToWig $PREFIX/bin/bigWigToWig
cp util/mappability/internal/fastaToRead $PREFIX/bin/fastaToRead
cp util/mappability/generateMap.pl $PREFIX/bin/generateMap.pl
cp util/mappability/internal/readToMap.pl $PREFIX/bin/readToMap.pl
cp util/renameChr.pl $PREFIX/bin/renameChr.pl
cp util/seg/segToGc $PREFIX/bin/segToGc
cp util/seg/segToMap $PREFIX/bin/segToMap
cp util/bigwig/wigToBigWig $PREFIX/bin/wigToBigWig
cp bin/* $PREFIX/bin
cd $PREFIX/bin
sed -i'.bak' "s,internal/,," generateMap.pl
sed -i'.bak' "s,../renameChr.pl,renameChr.pl," generateMap.pl
sed -i'.bak' "s,../bigwig/,," generateMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," generateMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," readToMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," renameChr.pl
rm *.bak
