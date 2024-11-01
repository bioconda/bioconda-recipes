#!/bin/bash
set -euo pipefail

echo "Building Eagle2 version ${PKG_VERSION}"

make \
    -e \
    -j 4 \
    DYN_LIBS="-lz -lpthread -lbz2 -lblas" \
    CXX="$CXX -std=c++17" \
    CXXFLAG="$CXXFLAGS" \
    LDFLAG="$LDFLAGS" \
    PREFIX="${PREFIX}" \
    HTSLIB_INC="$PREFIX" \
    HTSLIB_LIB="-lhts" \
    BOOST_INC="$PREFIX/include"\
    BOOST_LIB_IO="-lboost_iostreams" \
    BOOST_LIB_PO="-lboost_program_options" \
    BOOST_LIB_SE="-lboost_serialization"  || exit 1

echo "Installing Eagle2..."
install
echo "Eagle2 installation completed successfully"
