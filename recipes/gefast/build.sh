#!/bin/bash
make install CXX=$CXX
mkdir -p $PREFIX/bin
mv GeFaST $PREFIX/bin
