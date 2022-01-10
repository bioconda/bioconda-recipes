#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##


# suppress warnings
# add -fopenmp to compilation due to viennarna setup
CXXFLAGS="$CXXFLAGS -w -fopenmp"; 
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";

if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++ -v"
    LDFLAGS="$LDFLAGS -stdlib=libc++ -v"
else ## linux
    CXXFLAGS="$CXXFLAGS"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}

if [ `uname` == Darwin ] ; then
    echo 
    echo "testing ld/clang options"
    echo
    man -P cat ld
    clang-11 -help
    echo
fi

./configure --prefix=$PREFIX \
            --with-vrna=$PREFIX \
            --with-boost=$PREFIX \
            --with-zlib=$PREFIX \
            --disable-log-coloring \
            --with-boost-libdir=$PREFIX/lib \
            --disable-intarnapvalue \
            ${extra_config_options}

if [ `uname` == Darwin ] ; then
  make 
  make tests
else
  make -j ${CPU_COUNT}
  make tests -j ${CPU_COUNT}
fi
make install
