#!/bin/bash

git clone git://git.code.sf.net/p/pstreams/code c++/pstreams
sed -ie 's#<pstreams/pstream.h>#"pstreams/pstream.h"#' c++/augment-bam.cpp
make -C c++
cp c++/augment-bam $PREFIX/bin
cp c++/brass-group $PREFIX/bin
cp c++/filterout-bam $PREFIX/bin
