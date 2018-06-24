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

make

for i in $binaries; do cp $i $BINDIR && chmod +x $BINDIR/$(basename $i); done
