#!/bin/bash
export HTSlib=${PREFIX}/htslib
rm -rf build
mkdir build
cd build
cmake ..
make -j2

mkdir -p $PREFIX/bin/

cp $PREFIX/build/tools/Compare ${PREFIX}/bin/
chmod +x $PREFIX/bin/Compare

cp $PREFIX/build/tools/BamExtractor ${PREFIX}/bin/
chmod +x $PREFIX/bin/BamExtractor

cp $PREFIXscripts/reads_bx_sqlite3.py ${PREFIX}/bin/
chmod +x $PREFIX/bin/reads_bx_sqlite3.py

cp $PREFIX/scripts/idx_bx_sqlite3.py ${PREFIX}/bin/
chmod +x $PREFIX/bin/idx_bx_sqlite3.py
