#!/bin/sh
set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

#compile
cmake -DGSL_LIBRARIES=${PREFIX}/include/gsl -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="Boost" -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_PREFIX_PATH="$PREFIX"

# for debugging
ls -l

# copy tools in the bin
#mkdir -p ${PREFIX}/bin
#for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
#  cp ${PROGRAM} ${PREFIX}/bin
#done
