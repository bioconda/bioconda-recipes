#!/bin/bash

#set -euo pipefail

echo "Building Eagle2 version ${PKG_VERSION}"

cd src

sed -i.bak '/memcpy.o/d' Makefile

# Set up environment variables for building
export BOOST_INSTALL_DIR=$PREFIX
export HTSLIB_DIR=$PREFIX
export BLAS_DIR=$PREFIX/lib
export ZLIB_STATIC_DIR=$PREFIX

# Run make
make CC=${CXX} \
    -e -j ${CPU_COUNT} \
    CFLAGS="$CXXFLAGS -Wno-unused-result" \
    BOOST_INSTALL_DIR=$BOOST_INSTALL_DIR \
    HTSLIB_DIR=$HTSLIB_DIR \
    BLAS_DIR=$BLAS_DIR \
    ZLIB_STATIC_DIR=$ZLIB_STATIC_DIR \
    linking=static-except-glibc

echo "Installing Eagle2..."
mkdir -p "${PREFIX}/bin"
install -m 755 eagle "${PREFIX}/bin/"
echo "Eagle2 installation completed successfully"
