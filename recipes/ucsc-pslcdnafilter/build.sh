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
#export COPT="${COPT} ${CFLAGS}"
export BINDIR="$(pwd)/bin"
export L="${LDFLAGS}"

mkdir -p "${BINDIR}"

cp -rf ${RECIPE_DIR}/straw.cpp kent/src/hg/lib/straw/straw.cpp
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* kent/src/htslib

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
  export EXTRA_ARGS="--host=arm64"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
  export EXTRA_ARGS="--host=aarch64"
else
  export EXTRA_ARGS="--host=x86_64"
fi

sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/lib/makefile
rm -rf kent/src/lib/*.bak
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/lib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/jkOwnLib/makefile
sed -i.bak 's|${XINC}|${XINC} $(LDFLAGS)|' kent/src/jkOwnLib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/cgilib/makefile
sed -i.bak 's|ld|$(LD)|' kent/src/hg/lib/straw/makefile
rm -rf kent/src/hg/lib/straw/*.bak

cd kent/src/htslib
autoreconf -if
./configure --enable-libcurl --enable-plugins \
        CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -Wl,-R${PREFIX}/lib" \
        CPPFLAGS="${CPPFLAGS}" --disable-option-checking "${EXTRA_ARGS}"
make -j"${CPU_COUNT}"
cp -f libhts.a ../lib/${MACHTYPE}/

cd ../../../

(cd kent/src && USE_HIC=1 make libs CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/pslCDnaFilter && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
install -v -m 0755 bin/pslCDnaFilter "${PREFIX}/bin"
