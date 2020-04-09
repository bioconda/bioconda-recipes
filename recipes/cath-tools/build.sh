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
#conda install -p $PREFIX libgfortran=3.0 -y
# backup to "gfortran" in conda GFORTRAN is not set
#cmake CXX=${CXX} -DCMAKE_CXX_FLAGS="-stdlib=libc++"
cmake -DGSL_INCLUDES=${PREFIX}/include -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBOOST_ROOT=$PREFIX -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="Boost" -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_PREFIX_PATH="$PREFIX"
# copy tools in the bin
#mkdir -p ${PREFIX}/bin
#for PROGRAM in ${PFTOOLS_PROGRAMS} ; do
#  cp ${PROGRAM} ${PREFIX}/bin
#done
