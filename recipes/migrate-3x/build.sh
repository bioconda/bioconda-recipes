#!/bin/bash


cd src

## gcc claims that this is old-fashioned!
sed -i.bak 's/#include <xlocale.h>//' data.c
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
#echo "@@============="
export CFLAGS="$CFLAGS -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
./configure --prefix=$PREFIX  --with-zlib=shipped
#echo "%%%%%%%%%%"
#echo $LIBRARY_PATH
#echo $LDFLAGS
#pkg-config zlib --libs
#echo "%%%%%%%%%%"
make
#echo "finished Make"
mkdir -p $PREFIX/bin
cp $SRC_DIR/src/migrate-n $PREFIX/bin
#echo "copied migrate-n into the bin directory"
