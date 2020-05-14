#!/bin/sh
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="$CFLAGS -I${C_INCLUDE_PATH}"
export LDFLAGS="$LDFLAGS -L$LIBRARY_PATH"

wget http://ccb.jhu.edu/software/stringtie/dl/prepDE.py

pushd samtools-0.1.18
make CC=${CC} CFLAGS="${CFLAGS}" lib
popd

make release CC=$CXX LINKER=$CXX LFLAGS=${LDFLAGS}
mkdir -p $PREFIX/bin
mv stringtie $PREFIX/bin

if [ "$PY3K" == 1 ]; then
    2to3 -w prepDE.py
fi
sed -i.bak 's|/usr/bin/env python2|/usr/bin/env python|' prepDE.py
mv prepDE.py $PREFIX/bin
chmod +x $PREFIX/bin/prepDE.py
