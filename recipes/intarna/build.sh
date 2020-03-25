#!/bin/bash

## Choose extra configure options depending on the operating system
## (mac or linux)
##


# suppress warnings
# add -fopenmp to compilation due to viennarna setup
CXXFLAGS="$CXXFLAGS -w -fopenmp"; 
LDFLAGS="$LDFLAGS -Wl,-rpath ${PREFIX}/lib";

if [ `uname` == Darwin ] ; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    LDFLAGS="$LDFLAGS -stdlib=libc++"
else ## linux
    CXXFLAGS="$CXXFLAGS"
fi

export CC=${CC}
export CXX=${CXX}
export CXXFLAGS=${CXXFLAGS}
export LDFLAGS=${LDFLAGS}

./configure --prefix=$PREFIX \
            --with-vrna=$PREFIX \
            --with-boost=$PREFIX \
            --with-zlib=$PREFIX \
            --disable-log-coloring \
            --with-boost-libdir=$PREFIX/lib \
            --disable-intarnapvalue \
            ${extra_config_options}
            
make -j 2
make tests -j 2
make install
