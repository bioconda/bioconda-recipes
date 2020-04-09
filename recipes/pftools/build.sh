#!/bin/sh
set -x -e

export CFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

#compile
#conda install -p $PREFIX libgfortran=3.0 -y
# backup to "gfortran" in conda GFORTRAN is not set
GFORTRAN=${GFORTRAN:-gfortran}
make CC=${GFORTRAN} CFLAGS="$CXXFLAGS $LDFLAGS" io.o pfscan pfsearch

# copy tools in the bin
mkdir -p ${PREFIX}/bin
cp pfscan pfsearch ${PREFIX}/bin
