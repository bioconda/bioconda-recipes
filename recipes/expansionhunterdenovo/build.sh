#!/bin/sh
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../source
make
cp ExpansionHunterDenovo $PREFIX/bin/ExpansionHunterDenovo