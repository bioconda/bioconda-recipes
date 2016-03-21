#!/bin/sh
make
mkdir $PREFIX/bin
mv svm-train $PREFIX/bin
mv svm-scale $PREFIX/bin
mv svm-predict $PREFIX/bin
