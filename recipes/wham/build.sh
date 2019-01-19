#!/bin/bash
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

sed -i.bak '/^CC=/s/^/#/g' Makefile
sed -i.bak '/^CXX=/s/^/#/g' Makefile
sed -i.bak 's#cmake ..#cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_INSTALL_INCLUDEDIR=${PREFIX}/include -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib ..#' Makefile
sed -i.bak 's/$(LIBS)/-L${LIBRARY_PATH} -I${C_INCLUDE_PATH} ${LIBS}/g' Makefile
sed -i.bak '/^CC =/s/^/#/g' src/Complete-Striped-Smith-Waterman-Library/src/Makefile
sed -i.bak '/^CXX =/s/^/#/g' src/Complete-Striped-Smith-Waterman-Library/src/Makefile
sed -i.bak '/^CXX=/s/^/#/g' src/fastahack/Makefile
sed -i.bak 's/-lm -lz/-L${LIBRARY_PATH} -I${C_INCLUDE_PATH} -lm -lz/' src/Complete-Striped-Smith-Waterman-Library/src/Makefile

make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
