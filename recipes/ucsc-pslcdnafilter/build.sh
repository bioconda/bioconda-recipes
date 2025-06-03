#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"
export MACHTYPE="$(uname -m)"
export BINDIR="$(pwd)/bin"
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
#export COPT="${COPT} ${CFLAGS}"
#export L="${LDFLAGS}"
export kentSrc="${SRC_DIR}/kent/src"

mkdir -p "${BINDIR}"

cp -rf ${RECIPE_DIR}/straw.cpp kent/src/hg/lib/straw/straw.cpp
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* kent/src/htslib

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument"
        LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
        export EXTRA_ARGS="--host=arm64"
        mkdir -p kent/src/lib/arm64
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
        export EXTRA_ARGS="--host=aarch64"
        mkdir -p kent/src/lib/aarch64
else
        export EXTRA_ARGS="--host=x86_64"
fi

sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/lib/makefile
rm -rf kent/src/lib/*.bak
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/lib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/jkOwnLib/makefile
sed -i.bak 's|-O -g|-O3 -g|' kent/src/hg/lib/straw/makefile
sed -i.bak 's|${XINC}|${XINC} $(LDFLAGS)|' kent/src/jkOwnLib/makefile
sed -i.bak 's|-o $@ -c $<|-c $< -o $@|' kent/src/jkOwnLib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/cgilib/makefile
sed -i.bak 's|ld|$(LD)|' kent/src/hg/lib/straw/makefile
rm -rf kent/src/hg/lib/straw/*.bak

cd kent/src/htslib
autoreconf -if
./configure --enable-libcurl --enable-plugins \
        CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
        CPPFLAGS="${CPPFLAGS}" --disable-option-checking "${EXTRA_ARGS}"
make clean
make -j"${CPU_COUNT}"
cp -f libhts.a ../lib/${MACHTYPE}/

cd ../../../

(cd kent/src && USE_HIC=1 make libs CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
(cd kent/src/hg/pslCDnaFilter && make CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}")
install -v -m 0755 bin/pslCDnaFilter "${PREFIX}/bin"
