#!/bin/bash

mkdir -p $PREFIX/bin
g++ -O3 -o Sparc *.cpp
mv Sparc $PREFIX/bin
sed -i.bak 's|\./||g' utility/split_and_run_sparc.sh
chmod a+x utility/*.sh
mv utility/* $PREFIX/bin
