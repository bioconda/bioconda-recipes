#!/bin/bash
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DPacBioBAM_build_docs=OFF -DPacBioBAM_build_tests=OFF
make
cp lib/* $PREFIX/lib
cp bin/* $PREFIX/bin