#!/bin/sh
cd segemehl

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make -j 1 ## do not use >1 make threads!

install -t $PREFIX/bin *.x
