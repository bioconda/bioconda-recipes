#!/bin/bash

cd src
if [ `uname` == Darwin ]; then
    LDFLAGS=$LDFLAGS" -lomp" make
else
    make
fi
mkdir -p $PREFIX/bin
cp ../build/bin/merfin $PREFIX/bin/

