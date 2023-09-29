#!/bin/bash

rm -rf build
mkdir -p build/mimalloc
cd build/mimalloc
cmake ../../mimalloc
make -j2 mimalloc-static
cd ../..


LIBS="${LDFLAGS}" make -j4 CC="${CC}" CXX="${CXX}" multi

cd RMI && cargo build --release && cd ..
cp RMI/target/release/bwa-meme-train-prmi $PREFIX/bin
cp build_rmis_dna.sh $PREFIX/bin



mkdir -p $PREFIX/bin
cp bwa-meme* $PREFIX/bin


