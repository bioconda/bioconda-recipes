#!/bin/bash
./configure
make CXXFLAGS="${CXXFLAGS} -std=c++03"

cp allegro $PREFIX/bin
