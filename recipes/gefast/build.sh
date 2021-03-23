#!/bin/bash
make CXX=$CXX
mkdir -p $PREFIX/bin
mv build/GeFaST $PREFIX/bin
