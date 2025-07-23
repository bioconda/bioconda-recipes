#!/bin/bash

mkdir -p $PREFIX/bin
cd gctb_2.0_scr/scr
sed -i "15c\EIGEN =$PREFIX/include/eigen3" Makefile
sed -i "16c\BOOST=$PREFIX/include" Makefile
if [[ ${target_platform} == "linux-aarch64" ]]; then
 sed -i "23s/-m64 //" Makefile
 sed -i "23s/-msse2 //" Makefile
 sed -i "27s/-static //" Makefile
 sed -i "27s/-m64 //" Makefile
fi
make $CC $CXX
cp gctb $PREFIX/bin/
