#!/bin/bash

if [ `uname` == Darwin ] ; then
    MACOSX_DEPLOYMENT_TARGET=10.9
fi
echo $MACOSX_DEPLOYMENT_TARGET
CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-L$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
make install

