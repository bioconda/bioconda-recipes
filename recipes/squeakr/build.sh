#!/bin/bash

mkdir -p $PREFIX/bin

if [ $UNAME == "Darwin" ]
then
    export CFLAGS="-stdlib=libc++"
    make
else
    make
fi

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin
