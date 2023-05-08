#!/bin/bash
mkdir libs/gcem/build
cd libs/gcem/build
cmake .. -DCMAKE_INSTALL_PREFIX=../../stats
make CXX=$CXX install
cd ../../..
make CXX=$CXX
mkdir -p $PREFIX/bin
mv build/GeFaST $PREFIX/bin
