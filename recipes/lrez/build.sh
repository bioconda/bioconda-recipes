#!/bin/bash
export HTSLIB_ROOT=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake ..
make -j2

mkdir -p $PREFIX/bin/

cp build/tools/Compare ${PREFIX}/bin/
chmod +x $PREFIX/bin/Compare

cp build/tools/BamExtractor ${PREFIX}/bin/
chmod +x $PREFIX/bin/BamExtractor

cp scripts/reads_bx_sqlite3.py ${PREFIX}/bin/
chmod +x $PREFIX/bin/reads_bx_sqlite3.py

cp scripts/idx_bx_sqlite3.py ${PREFIX}/bin/
chmod +x $PREFIX/bin/idx_bx_sqlite3.py
