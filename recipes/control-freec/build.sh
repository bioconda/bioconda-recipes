#!/bin/bash


mkdir -p $PREFIX/bin

for f in scripts/*
do
    chmod +x $f
    pattern="s/\\/usr\\/bin\\/perl/${PREFIX//\//\\/}\\/bin\\/perl/"
    sed -i -e $pattern $f
    cp $f $PREFIX/bin
done

cd src
$CXX -o $PREFIX/bin/freec $CXXFLAGS $LDFLAGS *.cpp -lpthread
