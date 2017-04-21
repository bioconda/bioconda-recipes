#!/bin/bash

cd src
make

mkdir -p $PREFIX/bin
cp freec $PREFIX/bin
for f in scripts/*
do
    cp $f $PREFIX/bin
done

