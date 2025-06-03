#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE="$(uname -m)"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export COPT="${COPT} ${CFLAGS}"
export BINDIR="$(pwd)/bin"
export L="${LDFLAGS}"

mkdir -p "${BINDIR}"

if [[ "$(uname -s)" == "Darwin" ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi

sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/lib/makefile
rm -rf kent/src/lib/*.bak
sed -i.bak 's|ld|$(LD)|' kent/src/hg/lib/straw/makefile
rm -rf kent/src/hg/lib/straw/*.bak

(cd kent/src && USE_HIC=1 make libs CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/pslCDnaFilter && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
install -v -m 0755 bin/pslCDnaFilter "${PREFIX}/bin"
