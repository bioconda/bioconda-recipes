#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi
export CMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++"

chmod +x $SRC_DIR/build/*
make -j 2
make install prefix=$PREFIX
