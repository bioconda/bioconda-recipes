#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -std=c++11"

./configure --prefix=$PREFIX --enable-bam
make
make install
# copy missing scripts
cp -rp scripts/{convert_stacks.pl,extract_interpop_chars.pl} $PREFIX/bin/
