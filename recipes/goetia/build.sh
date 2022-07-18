#!/bin/bash

# cppyy's genreflex hard-codes file paths into the SO.
# so, we need to make sure the headers are in their final
# resting place during generation
mv include/goetia ${PREFIX}/include/
export CONDA_BUILD_DEPLOY=1

# now do build
mkdir build
cd build

# we don't have git tags so set version manually
export GOETIA_VERSION=${PKG_VERSION}

CONDA_PREFIX=${PREFIX} cmake .. -DCMAKE_BUILD_TYPE=Release \
                                -DCMAKE_INSTALL_PREFIX=${PREFIX} \
                                -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include \
                                -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
                                -DBUILD_SHARED_LIBS=TRUE \
                                -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
                                -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE
make install VERBOSE=1
