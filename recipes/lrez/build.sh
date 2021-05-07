#!/bin/bash

# Change path to point to conda install
if [ "$(uname)" == "Darwin" ]; then
	sed -i '' -e "s#../barcodes/#..share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/#" src/main.cpp
else
	sed -i'' -e "s#../barcodes/#..share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/#" src/main.cpp
fi

make -j"${CPU_COUNT}" \
    BUILD_BINDIR='$(BUILD_PREFIX)' \
    BUILD_LIBDIR='$(BUILD_PREFIX)'
make install \
    BUILD_BINDIR='$(BUILD_PREFIX)' \
    BUILD_LIBDIR='$(BUILD_PREFIX)'

# install barcodes files
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
cp barcodes/* $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/
