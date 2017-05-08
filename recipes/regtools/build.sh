#!/usr/bin/env bash
mkdir build
cd build/
cmake ..
make
cp regtools $PREFIX/bin
chmod +x $PREFIX/bin/regtools
