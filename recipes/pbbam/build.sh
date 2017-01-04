#!/bin/bash
mkdir build
cd build
export CXXFLAGS="${CXXFLAGS} -std=c++0x"
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DPacBioBAM_build_docs=OFF -DPacBioBAM_build_tests=OFF
make 
cp lib/* $PREFIX/lib
cp bin/* $PREFIX/bin