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
sed -i.bak "s#gcc#${CC}#g;s#g++#${CXX}#g" Makefile.freec
make 
cp freec $PREFIX/bin
