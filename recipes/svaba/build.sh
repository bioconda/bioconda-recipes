#!/bin/bash
set -eu -o pipefail

# Build htslib which is needed by SeqLib (a submodule of SvABA)
./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make install

# Make sure that SeqLib can find htslib
cd SeqLib
ln -s ../htslib .
cd ..

# Build SvABA
cmake -DHTSLIB_DIR=htslib
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp svaba ${PREFIX}/bin/
