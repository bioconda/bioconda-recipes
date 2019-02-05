#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

wget https://github.com/stevengj/nlopt/archive/v2.5.0.tar.gz
tar xf v2.5.0.tar.gz
cd nlopt-2.5.0/
mkdir -p build/
cd build/
cmake -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib  -DNLOPT_OCTAVE=Off -DNLOPT_MATLAB=Off -DNLOPT_GUILE=Off -DBUILD_SHARED_LIBS=OFF ..
make
make install
cd ../..
make -f Makefile.bioconda PREFIX=${PREFIX}
make -f Makefile.bioconda install PREFIX=${PREFIX}

