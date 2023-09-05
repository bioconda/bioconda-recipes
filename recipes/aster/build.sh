#!/bin/bash

sed -i.bak1 's/-march=native/-march=x86-64 -mtune=generic/g' makefile
if [ "$(uname)" == "Darwin" ];
then
    sed -i.bak2 's/g++/${CXX}/g' makefile
    make mac
else
    sed -i.bak2 's/g++/${GXX}/g' makefile
    make
fi

[ ! -d $PREFIX/bin ] && mkdir -p $PREFIX/bin

cp bin/* $PREFIX/bin/
chmod a+x $PREFIX/bin/*
