#!/bin/bash

mkdir -p $PREFIX/bin

# Source archive contains some macOS junk files,
# which prevent hoisting the HMMcopy on Linux only.
cd HMMcopy || True
cmake .
make -j"${CPU_COUNT}"

sed -i'.bak' "s,internal/,," util/mappability/generateMap.pl
sed -i'.bak' "s,../renameChr.pl,renameChr.pl," util/mappability/generateMap.pl
sed -i'.bak' "s,../bigwig/,," util/mappability/generateMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," util/mappability/generateMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," util/mappability/internal/readToMap.pl
sed -i'.bak' "s,/usr/bin/perl -w,/usr/bin/env perl," util/renameChr.pl

rm -rf util/mappability/*.bak
rm -rf util/mappability/internal/*.bak
rm -rf util/*.bak

install -v -m 0755 util/bigwig/bigWigInfo util/bigwig/bigWigSummary \
	util/bigwig/bigWigToBedGraph util/bigwig/bigWigToWig \
	util/mappability/internal/fastaToRead util/mappability/generateMap.pl \
	util/mappability/internal/readToMap.pl util/renameChr.pl \
	util/seg/segToGc util/seg/segToMap \
	util/bigwig/wigToBigWig bin/* "${PREFIX}/bin"
