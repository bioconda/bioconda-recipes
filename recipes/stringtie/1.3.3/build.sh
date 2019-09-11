#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

wget http://ccb.jhu.edu/software/stringtie/dl/prepDE.py

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin

if [ "$PY3K" == 1 ]; then
    2to3 -w prepDE.py
fi
sed -i.bak 's|/usr/bin/env python2|/usr/bin/env python|' prepDE.py
mv prepDE.py $PREFIX/bin
chmod +x $PREFIX/bin/prepDE.py
