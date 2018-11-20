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

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
# needed because it is otherwise reported that SIZE_MAX is undefined
make FLAGS="-O3 -D__WITH_POOL__ -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS "

for i in $binaries; do cp $i $BINDIR && chmod +x $BINDIR/$(basename $i); done
