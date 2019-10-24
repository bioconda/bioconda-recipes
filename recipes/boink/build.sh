#!/bin/bash

mkdir build
cd build
export BOINK_VERSION=${PKG_VERSION}
CONDA_PREFIX=${PREFIX} cmake .. -DCMAKE_BUILD_TYPE=Release \
                                -DCMAKE_INSTALL_PREFIX=${PREFIX} \
                                -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
                                -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
                                -DBUILD_SHARED_LIBS=TRUE \
                                -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
                                -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE
make install VERBOSE=1
ls $PREFIX/lib/
