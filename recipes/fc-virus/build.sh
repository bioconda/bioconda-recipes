#!/bin/bash

#export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
#export CPATH=${PREFIX}/include
#export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
#export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
#export PATH=$BUILD_PREFIX/bin:$PATH
set -xe
#make \
#  CXX="${CXX}" \
#  CFLAGS="${CFLAGS} "
#chmod 777 ./bin/fc-virus
#install -d "${PREFIX}/bin"
#install ./bin/fc-virus "${PREFIX}/bin/"

make CXX="${CXX}" INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -L$PREFIX/lib"
#chmod +x fc-virus
chmod 777 ./bin/fc-virus

mkdir -p ${PREFIX}/bin
cp -f ./bin/fc-virus ${PREFIX}/bin

