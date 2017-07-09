#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/include/fast5

cp src/fast5.hpp $PREFIX/include/fast5/
cp src/hdf5_tools.hpp $PREFIX/include/fast5/
cp src/Bit_Packer.hpp $PREFIX/include/fast5/
cp src/File_Packer.hpp $PREFIX/include/fast5/
cp src/Huffman_Packer.hpp $PREFIX/include/fast5/
cp src/fast5_version.hpp $PREFIX/include/fast5/
cp src/logger.hpp $PREFIX/include/fast5/
cp src/*inl $PREFIX/include/fast5/
