#!/usr/bin/env bash

set -xe

export HAS_GTEST=0

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

make -j ${CPU_COUNT} CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"
mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
