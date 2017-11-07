#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
CXXFLAGS="$CXXFLAGS -w"; # suppress warnings
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";
CXX=g++;
CC=gcc;
if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
    CXX=clang++;
    CC=clang;
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    CXXFLAGS="$CXXFLAGS -fopenmp"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}

./configure --prefix=$PREFIX \
            --with-vrna=$PREFIX \
            --with-boost=$PREFIX \
            --disable-multithreading \
            --disable-log-coloring \
            ${extra_config_options} \
            
make
make install
