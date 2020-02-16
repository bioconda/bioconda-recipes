#!/bin/bash 

set -x
mkdir -p build
cd build
export C_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export TOOLSET=gcc
export BOOST_ROOT=${PREFIX}
export HTSLIB_ROOT=${PREFIX}
export HTSLIB_LIBRARY_DIR=${PREFIX}/lib
export HTSLIB_INCLUDE_DIR=${PREFIX}/include
export CXXFLAGS="-ldeflate -lrt -lm -lz -llzma -lbz2 -ldl"

#tricks down stream to skip builds of packages already in bioconda
mkdir -p $SRC_DIR/build/include/htslib
#mkdir -p $SRC_DIR/build/scratch/zlib-1.2.8/
#touch $SRC_DIR/build/scratch/zlib-1.2.8/libz.a
mkdir -p $SRC_DIR/build/bin
touch $SRC_DIR/build/bin/samtools
touch $SRC_DIR/build/bin/bcftools

#if [ ! -d ${ISD}/include/htslib ] ;
#sed -i.bak -e '/include\/htslib/s/\!//' external/make_dependencies.sh


cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DBOOST_ROOT="${PREFIX}" -DBoost_NO_SYSTEM_PATHS=ON -DCMAKE_BUILD_TYPE=Release \
  -DHTSLIB_ROOT="${PREFIX}"
make
rm -f lib/libhts*so
make install
