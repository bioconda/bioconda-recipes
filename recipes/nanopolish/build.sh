#!/bin/bash
export CFLAGS="-I$PREFIX/include -std=c99"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

export HTS_LIB=${PREFIX}/lib/libhts.a
export HTS_INCLUDE=-I${PREFIX}/include
export FAST5_INCLUDE=-I${PREFIX}/include/fast5

mkdir -p $PREFIX/bin

ls -l minimap2
make HDF5=noinstall EIGEN=noinstall HTS=noinstall MINIMAP2=noinstall
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
# cp scripts/consensus-preprocess.pl $PREFIX/bin # Skipping this pre-processing step at the moment.
