#!/bin/bash
make CXX=$CXX
mkdir -p $PREFIX/bin
mv GeFaST $PREFIX/bin
