#!/bin/sh

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make release
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin

# Prepare prepDE
# This is equivalent to https://github.com/gpertea/stringtie/blob/master/prepDE.py
curl -LO http://ccb.jhu.edu/software/stringtie/dl/prepDE.py
if [ "$PY3K" == 1 ]; then
    2to3 -w --no-diffs prepDE.py
fi
sed -i.bak 's|/usr/bin/env python2|/usr/bin/env python|' prepDE.py
mv prepDE.py $PREFIX/bin
chmod +x $PREFIX/bin/prepDE.py
