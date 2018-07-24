#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/include/fast5

cp include/fast5.hpp $PREFIX/include/fast5/
cp include/fast5/hdf5_tools.hpp $PREFIX/include/fast5/
cp include/fast5/Bit_Packer.hpp $PREFIX/include/fast5/
#cp include/fast5/File_Packer.hpp $PREFIX/include/fast5/
cp include/fast5/Huffman_Packer.hpp $PREFIX/include/fast5/
cp include/fast5/fast5_version.hpp $PREFIX/include/fast5/
cp include/fast5/logger.hpp $PREFIX/include/fast5/
cp include/fast5/*inl $PREFIX/include/fast5/
