#!/bin/sh
make install prefix=$PREFIX

# used by tophat --with-bam
mv libbam.a $PREFIX/lib/
mkdir -p $PREFIX/include/bam
ln -s version.h version.hpp
mv *.h *.hpp $PREFIX/include/bam
