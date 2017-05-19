#!/bin/bash

if [ `uname` == Darwin ]; then
        export MACOSX_DEPLOYMENT_TARGET=10.9
fi

cd $PREFIX
cmake $SRC_DIR
make -j 2
