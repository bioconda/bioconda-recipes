#!/bin/bash


cd $SRC_DIR/src
sed -i.bak 's/#include <xlocale.h>//' src/data.c
sed -i "s/MIGRATEGITVERSION = \$(shell . showgit.sh)/MIGRATEGITVERSION = Distribution/" Makefile.in
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CFLAGS="$CFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
./configure --prefix=$PREFIX
sed -i.bak 's/-lz/-L${LIBRARY_PATH} -I${C_INCLUDE_PATH} -lz -lstdc++/' Makefile
make thread
mkdir -p $PREFIX/bin
cp $SRC_DIR/src/migrate-n $PREFIX/bin/migrate-n-4.4.4

