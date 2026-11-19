#!/bin/bash
set -euo pipefail

cd "$SRC_DIR"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include -I${SRC_DIR}/src/deps/libdeflate"
export CFLAGS="${CFLAGS:-} -fPIC"
export CXXFLAGS="${CXXFLAGS:-} ${CPPFLAGS}"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"

rm -f inst/stringtie inst/stringtie3/stringtie inst/gffcompare inst/trmap inst/.trmap.*
find inst -name .DS_Store -delete
mkdir -p inst/stringtie3
rm -rf src/deps/libdeflate/build
cmake -S src/deps/libdeflate -B src/deps/libdeflate/build \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="$CC" \
    -DLIBDEFLATE_BUILD_SHARED_LIB=OFF -DLIBDEFLATE_BUILD_GZIP=OFF
cmake --build src/deps/libdeflate/build --parallel "${CPU_COUNT:-1}"

make -C src/deps/htslib distclean CC="$CC" AR="$AR" RANLIB="$RANLIB"
make -C src/deps/htslib -j"${CPU_COUNT:-1}" libhts.a \
    CC="$CC" AR="$AR" RANLIB="$RANLIB" \
    CPPFLAGS="$CPPFLAGS" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"

make -C src/gffcompare clean CXX="$CXX" LINKER="$CXX"
make -C src/gffcompare -j"${CPU_COUNT:-1}" release \
    CXX="$CXX" LINKER="$CXX" LDFLAGS="$LDFLAGS"
for tool in stringtie stringtie3; do
    make -C "src/$tool" clean CXX="$CXX" LINKER="$CXX"
    make -C "src/$tool" -j"${CPU_COUNT:-1}" release \
        CXX="$CXX" LINKER="$CXX" LDFLAGS="$LDFLAGS" \
        LIBS="../deps/htslib/libhts.a ../deps/libdeflate/build/libdeflate.a -lz -llzma -lbz2 -lm -pthread"
done
make -C src install-tools

# The executables are already built and installed under inst.
"$R" CMD INSTALL --build --no-libs .
