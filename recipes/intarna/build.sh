#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
CXXFLAGS="$CXXFLAGS";
LDFLAGS="$LDFLAGS";
if [ `uname` == Darwin ] ; then
# enable c++11 support
    #echo;
    #echo "PREFIX/lib";
    #ls -l $PREFIX/lib;
    #echo "PREFIX/lib/pkgconfig";
    #ls -l $PREFIX/lib/pkgconfig/boost*;
    #cat $PREFIX/lib/pkgconfig/boost*;
    #cat $PREFIX/lib/pkgconfig/RNAlib*;
    #echo "otool"
    otool -L $PREFIX/lib/libboost_program_options.dylib
    #echo;
    MACOSX_VERSION_MIN=10.6
    CC=clang
    CXX=clang++
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LDFLAGS="${LDFLAGS} -stdlib=libc++ -mmacosx-version-min=${MACOSX_VERSION_MIN} -L${PREFIX}/lib"
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    CC=gcc
    CXX=g++
    CXXFLAGS="-fopenmp"
fi

export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}
export CC=${CC}
export CXX=${CXX}

./configure --prefix=$PREFIX \
            --with-RNA=$PREFIX \
            --with-boost=$PREFIX \
            --disable-multithreading \
            ${extra_config_options} \
            && \
make && \
make install
