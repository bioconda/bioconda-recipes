#! /bin/bash

mkdir -p $PREFIX/share/ncbi
./configure --prefix=$PREFIX --with-ngs-sdk-prefix=$PREFIX --build-prefix=$PREFIX/share/ncbi
# sra-tools also needs the sources
rsync -amP --include="*/" --include="*.h" --include="*.c" --include="*.hpp" --include="*.cpp" --exclude="*" $SRC_DIR/ $PREFIX/share/ncbi/ncbi-vdb
make -j 2
make install
