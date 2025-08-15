#!/bin/bash

OS=$(uname)
ARCH=$(uname -m)
cp -rf ${RECIPE_DIR}/sse2neon.h BMEAN/Complete-Striped-Smith-Waterman-Library/src/
# Fixes CONSENT-correct Segmentation fault: https://github.com/morispi/CONSENT/issues/32#issuecomment-1063116181
cp -rf src/robin_hood.h BMEAN/

# Fix zlib error
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Fix some error can't be patch before
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp  # Fix matrix path
else
    sed -i'' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp  # Fix matrix path
fi

# build
make -C BMEAN/Complete-Striped-Smith-Waterman-Library/src default CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS} ${LDFLAGS} -Wall -pipe -O3" -j"${CPU_COUNT}"

mkdir -p BMEAN/spoa/build
cmake -DCMAKE_BUILD_TYPE=Release -BBMEAN/spoa/build BMEAN/spoa/
make -C BMEAN/spoa/build -j"${CPU_COUNT}"

make -C BMEAN CXX="${CXX}" -j"${CPU_COUNT}"  # BMEAN make

mkdir -p bin
make CC="${CXX} -std=c++14" -j"${CPU_COUNT}"  # CONSENT make

# rename some binary
mv bin/explode bin/CONSENT-explode
mv bin/merge bin/CONSENT-merge
mv bin/reformatPAF bin/CONSENT-reformatPAF

# install matrix
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp -rf BMEAN/blosum80.mat $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/

# install bin
mkdir -p $PREFIX/bin/
install -v -m 0755 bin/* $PREFIX/bin
install -v -m 0755 CONSENT-correct $PREFIX/bin
install -v -m 0755 CONSENT-polish $PREFIX/bin
