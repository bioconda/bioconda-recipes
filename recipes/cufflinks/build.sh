#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"

# fix automake
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

# fix autoconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate


# Tell cufflinks to use GCC no matter what
export CC=${PREFIX}/bin/gcc
export GCC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++
export CCC=${PREFIX}/bin/g++
export CPP=${PREFIX}/bin/cpp
export LD=${PREFIX}/bin/gcc

export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
export LIBS='-lboost_regex -lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'

export BAMTOOLS_INCLUDE_DIR="${PREFIX}/include/bamtools/"
export BAMTOOLS_LIBRARY_DIR="${PREFIX}/lib/"

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} -lboost_regex -lboost_filesystem -lboost_system"
export LDFLAGS="${LDFLAGS} -static-libgcc -static-libstdc++"


#autoreconf --install
./autogen.sh
./configure --prefix=$PREFIX \
   --with-boost-libdir=${PREFIX}/lib \
   --with-boost=${PREFIX} \
   --with-eigen=${PREFIX} \
   --with-zlib=${PREFIX}

exit 1
