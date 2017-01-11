#!/usr/bin/env bash

mkdir build
cd build

if [ `uname` == Darwin ]; then
    DCMTK_HOME=$PREFIX \
    cmake \
        -DCMAKE_FIND_ROOT_PATH=$PREFIX \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=10.8                                      \
        -DCMAKE_CXX_FLAGS="-mmacosx-version-min=10.8 -std=c++11 -stdlib=libc++" \
        -DCMAKE_SHARED_LINKER_FLAGS="-mmacosx-version-min=10.8 -stdlib=libc++"  \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" ..
fi

if [ `uname` == Linux ]; then
    DCMTK_HOME=$PREFIX \
    cmake \
        -DCMAKE_FIND_ROOT_PATH=$PREFIX \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} ..
fi

make -j${CPU_COUNT}
make install

