#!/bin/bash


mkdir -p $PREFIX/bin

for f in scripts/*
do
    chmod +x $f
    cp $f $PREFIX/bin
done

cd src
make
cp freec $PREFIX/bin
