#!/bin/sh
mkdir -p $PREFIX/bin
make
mv svm-train $PREFIX/bin
mv svm-scale $PREFIX/bin
mv svm-predict $PREFIX/bin

cp tools/*py $PREFIX/bin
