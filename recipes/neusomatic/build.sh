#!/bin/bash

target=$PREFIX/opt/neusomatic

pushd neusomatic
  mkdir build
  pushd build
    cmake -DCMAKE_INCLUDE_PATH=${PREFIX}/include -DCMAKE_LIBRARY_PATH=${PREFIX}/lib ..
    make
  popd
popd


mkdir -p $target/neusomatic
mkdir -p $PREFIX/bin

cp -r neusomatic/{python,models} $target
cp -r bin/* $PREFIX/bin

for f in $target/python/*
do
    t=`basename $f`
    ln -s $f $PREFIX/bin/$t
done

