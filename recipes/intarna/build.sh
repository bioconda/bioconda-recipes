#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##
CXXFLAGS="$CXXFLAGS -w"; # suppress warnings
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";

if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
else ## linux
    # add -fopenmp to compilation due to viennarna setup
    CXXFLAGS="$CXXFLAGS -fopenmp"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}

if [ `uname` == Darwin ] ; then
CONFIGURE_MULTITHREADING="--disable-multithreading"
else ## linux
CONFIGURE_MULTITHREADING=""
fi

./configure --prefix=$PREFIX \
            --with-vrna=$PREFIX \
            --with-boost=$PREFIX \
            $CONFIGURE_MULTITHREADING \
            --disable-log-coloring \
            --with-boost-libdir=$PREFIX/lib \
            ${extra_config_options}
            
make -j 2
make tests -j 2
make install
