#! /bin/bash

mkdir -p ${PREFIX}/bin

make HTSSRC="systemwide" CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" prefix=$PREFIX  CC="$CC" CXX="$CXX" FLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
mv ./ngsLCA ${PREFIX}/bin/
