#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -std=c++11"

./configure --prefix=$PREFIX --enable-bam
make
make install
