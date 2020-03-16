#!/bin/bash
#export CFLAGS="-Iminimap2 -I$PREFIX/include -std=c99"
#export CPATH=${PREFIX}/include

#export FAST5_INCLUDE=-I${PREFIX}/include/fast5

mkdir -p $PREFIX/bin

# Linker options aren't passed to minimap2
pushd minimap2
make CFLAGS="$CFLAGS" LIBS="-L$PREFIX/lib -lm -lz -pthread" libminimap2.a
popd

make
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
./nanopolish

# cp scripts/consensus-preprocess.pl $PREFIX/bin # Skipping this pre-processing step at the moment.
