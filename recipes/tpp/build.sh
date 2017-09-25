#!/bin/bash

BUILD_DIR="${SRC_DIR}/build"

export CXXFLAGS="${CXXFLAGS} -fPIC -w"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# TODO: mz5 support is nearly working but needs a few fixes in linking certain
# targets
#export HDF5_SUPPORT = 1
#export MZ5_SUPPORT  = 1

echo "INSTALL_DIR  = ${PREFIX}"      >  site.mk
echo "TPP_BASEURL  = /tpp"           >> site.mk
echo "TPP_DATADIR  = ${PREFIX}/data" >> site.mk

# build bundled dependencies
make --silent extern

# we don't want/need these extra binaries, especially since some may conflict
# with those provided by other conda packages
rm -rf $BUILD_DIR/bin/*

# These are the actual TPP targets that we want (we skip the Search target
# because those search engines are packaged separately in conda)
make --silent Quantitation
make --silent Validation
make --silent Visualization
make --silent Parsers
make --silent Util

# we don't want/need these extra libraries, especially since some may conflict
# with those provided by other conda packages
rm -rf $BUILD_DIR/lib/*

# build Mayu last because we actually do want to keep its libs
make --silent mayu

# Move everything to the final destination. This is done instead of 'make
# install' because that command will try to build everything that we've
# intentionally skipped
cp -R $BUILD_DIR/bin    $PREFIX
cp -R $BUILD_DIR/lib    $PREFIX
cp -R $BUILD_DIR/conf   $PREFIX
cp -R $BUILD_DIR/lic    $PREFIX
