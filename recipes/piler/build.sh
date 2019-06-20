#! /bin/bash

mkdir -p $PREFIX/bin
if [ -d "piler" ] # osx platform
then 
    cd piler
    make
    cp piler $PREFIX/bin
else  # linux
    sed -i 's/piler2/piler/' Makefile
    make
    cp piler $PREFIX/bin
fi
