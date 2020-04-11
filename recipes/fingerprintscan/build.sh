#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

#PROGRAMS="gtop pfmake pfscan pfw ptoh htop pfscale pfsearch psa2msa 2ft 6ft ptof"
#compile

#CPPFLAGS=${CPPFLAGS} LDFLAGS=${LDFLAGS} ./configure
LD_LIBRARY_PATH=${LD_LIBRARY_PATH} CPPFLAGS=${CPPFLAGS} LDFLAGS=${LDFLAGS} CXX=${CXX} ./configure

make
make check
make install

#for debug
ls -l

# copy tools in the bin
#mkdir -p ${PREFIX}/bin
#for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
#  cp ${PROGRAM} ${PREFIX}/bin
#done
