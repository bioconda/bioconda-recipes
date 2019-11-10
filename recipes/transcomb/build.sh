#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
export LIBS='-lboost_regex -lboost_system -lboost_program_options -lboost_filesystem -lboost_timer'

export BAMTOOLS_INCLUDE_DIR="${BUILD_PREFIX}/include/bamtools/"
export BAMTOOLS_LIBRARY_DIR="${BUILD_PREFIX}/lib/"

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR} -lboost_regex -lboost_filesystem -lboost_system"

mkdir build
cd build
CXX=$CXX cmake ../src -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX}
make CXX=$CXX

cd ..

cp TransComb $PREFIX/bin
cp build/Assemble $PREFIX/bin
cp build/CorrectName $PREFIX/bin
cp build/Pre_Alignment $PREFIX/bin
