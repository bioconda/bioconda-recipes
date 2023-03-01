#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include
cd ./dysgu
git clone --recurse-submodules https://github.com/samtools/htslib.git
cd ./htslib
git clone https://github.com/ebiggers/libdeflate.git
export CPPFLAGS+=" -I./libdeflate ${CPPFLAGS}"
autoreconf -i
./configure --enable-libcurl --with-libdeflate
make
cd ../../

#patch for v1.3.14
sed -i 's/k = max(e.plus, e.minus)/k = max(int(e.plus), int(e.minus))/g' dysgu/post_call_metrics.pyx

#$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m pip install .
