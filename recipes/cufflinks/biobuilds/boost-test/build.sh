#!/usr/bin/env  bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export EIGEN_CPPFLAGS="-I${PREFIX}/include/eigen3"
export PKG_CONFIG_PATH="${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"

export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib
export BOOSTLIBDIR=${PREFIX}/lib
export LIBS='-lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/eigen3 -I${PREFIX}/include/bam"
export CXXFLAGS="${CXXFLAGS} -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="${LDFLAGS} -L${BOOST_LIBRARY_DIR} -lboost_filesystem -lboost_system"

g++ -o boost-filesystem -lboost_filesystem /bioconda-recipes/recipes/cufflinks/biobuilds/boost-test/boost-filesystem.cpp
./boost-filesystem
