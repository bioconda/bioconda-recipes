#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE="$(uname -m)"
# kent ships lib/x86_64 and parasol/lib/x86_64 but no dir for any other arch,
# and "make libs" builds topLibs and hgLib in parallel, so hg/cgilib can ar into
# lib/${MACHTYPE} before lib/makefile has created it.
mkdir -p "kent/src/lib/${MACHTYPE}" "kent/src/parasol/lib/${MACHTYPE}"
# The GitHub archives carry no .git, so htslib's Makefile cannot generate htscodecs' version.h;
# write the line it would have written, from htscodecs' own configure.ac.
H=kent/src/submodules/htslib/htscodecs
if [[ ! -e "${H}/htscodecs/version.h" ]]; then
    v="$(awk '/^AC_INIT\(htscodecs,/ { match($0, /[0-9]+(\.[0-9]+)*/); print substr($0, RSTART, RLENGTH) }' "${H}/configure.ac")"
    echo "#define HTSCODECS_VERSION_TEXT \"${v}\"" > "${H}/htscodecs/version.h"
fi
export BINDIR="$(pwd)/bin"
mkdir -p "$(pwd)/bin"
export INCLUDE_PATH="${PREFIX}/include"
# htslib's Makefile assigns CPPFLAGS/CFLAGS outright, discarding the environment,
# so ${PREFIX}/include only reaches its compiles via gcc's own CPATH.
export CPATH="${PREFIX}/include"
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

# Built from source on every platform: UCSC's prebuilt osx-arm64 binaries have shipped with
# invalid code signatures (bioconda/bioconda-recipes#70167).
(cd kent/src && make libs PTHREADLIB=1 CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}")
(cd kent/src/utils/faNoise && make CC="${CC}" -j"${CPU_COUNT}")
install -v -m 755 bin/faNoise "${PREFIX}/bin"
