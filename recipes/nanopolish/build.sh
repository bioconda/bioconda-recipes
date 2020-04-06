#!/bin/bash
export CFLAGS="-Iminimap2 -I$PREFIX/include -std=c99"
export CPATH=${PREFIX}/include

export HTS_LIB=${PREFIX}/lib/libhts.a
export HTS_INCLUDE=-I${PREFIX}/include
export FAST5_INCLUDE=-I${PREFIX}/include/fast5

mkdir -p $PREFIX/bin

# Linker options aren't passed to minimap2
pushd minimap2
make CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LIBS="-L$PREFIX/lib -lm -lz -pthread" libminimap2.a
popd

make HDF5=noinstall EIGEN=noinstall HTS=noinstall MINIMAP=noinstall CXXFLAGS="$CXXFLAGS -Iminimap2 -g -O3" LDFLAGS="$LDFLAGS -pthread -fopenmp"
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
# cp scripts/consensus-preprocess.pl $PREFIX/bin # Skipping this pre-processing step at the moment.
