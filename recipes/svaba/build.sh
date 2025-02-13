#!/bin/bash
set -eu -o pipefail

cd htslib
./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make install
cd ..

cd SeqLib
ln -s ../htslib .
cd ..

cmake -DHTSLIB_DIR=htslib
make CC=${CC} CXX=${CXX} CFLAGS="-fcommon ${CFLAGS} -L${PREFIX}/lib" CXXFLAGS="-fcommon ${CXXFLAGS} -UNDEBUG -L${PREFIX}/lib" LDFLAGS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
