#! /bin/bash
binaries="\
misc/msToGlf \
misc/contamination \
misc/contamination2 \
misc/splitgl \
misc/thetaStat \
misc/printIcounts \
misc/NGSadmix \
misc/realSFS \
misc/smartCount \
misc/supersim \
angsd \
"
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

make LDFLAGS="-L=${PREFIX}/lib" C_INCLUDE_PATH="-I=${PREFIX}/include" CPLUS_INCLUDE_PATH="-I=${PREFIX}/include"

for i in $binaries; do cp $i $BINDIR && chmod +x $BINDIR/$(basename $i); done
