#!/bin/bash

mkdir -p "$PREFIX/bin"

if [[ ${target_platform} == "linux-aarch64" ]]; then
 cd gctb_2.0_scr/scr
 sed -i.bak "15c\EIGEN =$PREFIX/include/eigen3" Makefile
 sed -i.bak "16c\BOOST=$PREFIX/include" Makefile
 sed -i.bak "23s/-m64 //" Makefile
 sed -i.bak "23s/-msse2 //" Makefile
 sed -i.bak "27s/-static //" Makefile
 sed -i.bak "27s/-m64 //" Makefile
 make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"
 cp -f gctb "$PREFIX/bin"
else
 cp -f gctb_2.0_scr/gctb "$PREFIX/bin"
fi
