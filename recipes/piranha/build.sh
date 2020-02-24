#!/bin/sh

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BAMTOOLS_INCLUDE_PATH="${PREFIX}/include/bamtools"
export CXXFLAGS="-I${INCLUDE_PATH} -L${LIBRARY_PATH}"

autoconf
./configure --with-bam_tools_headers="$BAMTOOLS_INCLUDE_PATH" --with-bam_tools_library="$LIBRARY_PATH"
make CXX=${CXX}
make test
make install

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin/
