#!/bin/bash

pushd src
env -u PREFIX make
popd

mkdir -p $PREFIX/bin

if [ `uname` == Darwin ]; then
    cp Darwin-amd64/bin/* $PREFIX/bin/
    cp Darwin-amd64/lib/* $PREFIX/lib/
else
    cp Linux-amd64/bin/* $PREFIX/bin/
    cp Linux-amd64/lib/* $PREFIX/lib/
fi

