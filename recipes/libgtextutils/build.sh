#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # building the library requires an implementation of basic_stringbuf
    # from the c++ standard library
    # 10.9 seems to be the minimum possible deployment target
    MACOSX_DEPLOYMENT_TARGET=10.9
fi

./configure --prefix=$PREFIX
make
make install
