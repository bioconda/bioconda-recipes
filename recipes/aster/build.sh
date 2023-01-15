#!/bin/bash

if [ "$(uname)" == "Darwin" ];
then
    sed -i.bak 's/g++/${CXX}/g' makefile
    make mac
else
    sed -i.bak 's/g++/${GXX}/g' makefile
    make
fi

[ ! -d $PREFIX/bin ] && mkdir -p $PREFIX/bin

cp bin/* $PREFIX/bin/
chmod a+x $PREFIX/bin/*
