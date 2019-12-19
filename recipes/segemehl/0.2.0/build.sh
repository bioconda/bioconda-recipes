#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include:${PREFIX}/include/ncurses
export LIBRARY_PATH=${PREFIX}/lib

cd segemehl
make segemehl.x -j${CPU_COUNT}
make testrealign.x -j${CPU_COUNT}
make lack.x -j${CPU_COUNT}

for i in *.x ; do
    install ${i} ${PREFIX}/bin
done
