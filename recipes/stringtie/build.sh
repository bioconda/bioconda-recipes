#!/bin/bash

mkdir -p $PREFIX/bin
ln -sf $PREFIX/lib/libz.so.1 $PREFIX/lib/libz.so

export M4="${BUILD_PREFIX}/bin/m4"
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LINKER="$CXX"
export CXXFLAGS="$CPPFLAGS"

cd SuperReads_RNA/global-1
autoreconf -if
./configure CC="${CC}" CXX="${CXX}" LDFLAGS="${LDFLAGS}"
cd ../../htslib
autoreconf -if
./configure CC="${CC}" CXX="${CXX}" LDFLAGS="${LDFLAGS}"
cd ../

make release CXX="${CXX}" LINKER="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 stringtie $PREFIX/bin

# Prepare prepDE
# This is equivalent to https://github.com/gpertea/stringtie/blob/master/prepDE.py
curl -LO https://ccb.jhu.edu/software/stringtie/dl/prepDE.py
2to3 -w --no-diffs prepDE.py
sed -i.bak 's|/usr/bin/env python2|/usr/bin/env python|' prepDE.py
mv prepDE.py $PREFIX/bin
chmod +x $PREFIX/bin/prepDE.py
