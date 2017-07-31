#!/bin/sh

mkdir -p $PREFIX/bin

for i in \
    hera \
    hera_build;
do
    echo $i
    cp build/$i $PREFIX/bin
    chmod +x $PREFIX/bin/$i
done
