#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

#list programs
CATH_PROGRAMS=""

#compile
cmake -DGSL_LIBRARIES=${PREFIX}/include/gsl -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBoost_DEBUG=ON -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_PREFIX_PATH="$PREFIX" .
# for debugging
ls -l

make
# for debugging
ls -l

# copy tools in the bin
mkdir -p ${PREFIX}/bin
for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
  cp ${PROGRAM} ${PREFIX}/bin
	chmod a+x ${PREFIX}/bin/${PROGRAM}
done
