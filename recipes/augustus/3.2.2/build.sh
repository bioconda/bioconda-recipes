#!/bin/sh
set -x -e

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"

make
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

sed -i 's/#!\/usr\/bin\/perl/#!\/usr\/bin\/env perl/g' scripts/*

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/scripts/
mv config/* $PREFIX/config/

#Install perl reqs
#cpanm Cwd File::Basename FileHandle File::Path File::Spec::Functions Getopt::Long IO::File List::Util Term::ANSIColor
