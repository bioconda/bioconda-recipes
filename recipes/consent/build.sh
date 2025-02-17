#!/bin/bash

mkdir -p bin
cp -rf ${RECIPE_DIR}/sse2neon.h BMEAN/Complete-Striped-Smith-Waterman-Library/src/

# Fix zlib error
export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# Fix some error can't be patch before
if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp  # Fix matrix path
else
    sed -i'' -e "s#/BMEAN/BOA/blosum80.mat#/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/blosum80.mat#" src/main.cpp  # Fix matrix path
fi

if [[ "${ARCJ}" == "aarch64" || "${ARCH}" == "arm64" ]]; then
	export CONFIG_ARGS="arm_neon=1 aarch64=1"
else
	export CONFIG_ARGS=""
fi

# build
cd BMEAN
./install.sh

cd ../minimap2
make CC="${CC}" "${CONFIG_ARGS}" -j"${CPU_COUNT}"

cd ..

mkdir -p bin
make CC="$CXX -std=c++14" -j"${CPU_COUNT}"  # CONSENT make

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
