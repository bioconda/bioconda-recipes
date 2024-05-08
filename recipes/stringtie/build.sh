#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

ln -sf ${PREFIX}/lib/libz.so.1 ${PREFIX}/lib/libz.so

export INCLUDE_PATH="${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LINKER="${CXX}"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make release CXX="${CXX} ${LDFLAGS}" CXXFLAGS="${CXXFLAGS}" INCDIRS="${INCDIRS} -I${PREFIX}/include" -j${CPU_COUNT}
chmod 755 stringtie && mv stringtie ${PREFIX}/bin

# Prepare prepDE
# This is equivalent to https://github.com/gpertea/stringtie/blob/master/prepDE.py
curl -LO https://ccb.jhu.edu/software/stringtie/dl/prepDE.py
2to3 -w --no-diffs prepDE.py
sed -i.bak 's|/usr/bin/env python2|/usr/bin/env python|' prepDE.py
mv prepDE.py ${PREFIX}/bin
chmod +x ${PREFIX}/bin/prepDE.py
