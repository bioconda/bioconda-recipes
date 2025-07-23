#!/bin/bash

mkdir -p $PREFIX/bin
if [[ ${target_platform} == "linux-aarch64" ]]; then
 cd gctb_2.0_scr/scr
 sed -i "15c\EIGEN =$PREFIX/include/eigen3" Makefile
 sed -i "16c\BOOST=$PREFIX/include" Makefile
 sed -i "23s/-m64 //" Makefile
 sed -i "23s/-msse2 //" Makefile
 sed -i "27s/-static //" Makefile
 sed -i "27s/-m64 //" Makefile
 make CC=$CC CXX=$CXX
 cp gctb $PREFIX/bin/
else
 cp gctb_2.0_linux/gctb $PREFIX/bin/
fi

