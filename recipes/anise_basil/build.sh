#!/bin/bash

git submodule init
git submodule update --recursive

cd build
cmake ..
make -j 4 anise basil

cp bin/anise bin/basil ../scripts/filter_basil.py $PREFIX/bin/