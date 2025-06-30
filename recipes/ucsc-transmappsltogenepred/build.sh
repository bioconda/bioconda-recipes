#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE="$(uname -m)"
export BINDIR="$(pwd)/bin"
mkdir -p "$(pwd)/bin"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export COPT="${COPT} ${CFLAGS}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export L="${LDFLAGS}"

sed -i.bak 's|g++|$(CXX)|' kent/src/optimalLeaf/makefile
sed -i.bak 's|-g|-g -O3|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/jkOwnLib/makefile
sed -i.bak 's|ld|$(LD)|' kent/src/hg/lib/straw/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/lib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/cgilib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/lib/makefile
rm -rf kent/src/optimalLeaf/*.bak
rm -rf kent/src/jkOwnLib/*.bak
rm -rf kent/src/hg/lib/straw/*.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
    export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi

if [[ "$(uname -m)" == "arm64" ]]; then
    rsync -aP rsync://hgdownload.cse.ucsc.edu/genome/admin/exe/macOSX.arm64/transMapPslToGenePred .
    install -v -m 755 transMapPslToGenePred "${PREFIX}/bin"
else
    (cd kent/src && make libs PTHREADLIB=1 CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}")
    (cd kent/src/hg/utils/transMapPslToGenePred && make CC="${CC}" -j"${CPU_COUNT}")
    install -v -m 755 bin/transMapPslToGenePred "${PREFIX}/bin"
fi
