#!/bin/bash

# without these lines, -lz can not be found
export CXXFLAGS="$CXXFLAGS -L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

if [ $(uname -m) == "aarch64" ]; then
    echo "======= DEBUG before: $CXXFLAGS"
    export CXXFLAGS=$(echo $CXXFLAGS | sed 's#-include src/common/memcpyLink.h -Wl,--wrap=memcpy##')
    echo "======= DEBUG after: $CXXFLAGS"
fi

mkdir -p $PREFIX/bin

./bootstrap.sh
./configure --prefix=$PREFIX --with-gsl=$PREFIX

make -j ${CPU_COUNT}
make install
