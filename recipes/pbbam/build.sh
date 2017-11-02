#!/bin/bash
mkdir build
cd build

if [ `uname` == Darwin ]; then
    export CXXFLAGS="${CXXFLAGS} -std=c++0x -stdlib=libc++"
fi
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -DCMAKE_INSTALL_INCLUDEDIR=$PREFIX/include -DPacBioBAM_build_docs=OFF -DPacBioBAM_build_tests=OFF
make 
#ls lib 
#ls bin
#ls include
#cp lib/* $PREFIX/lib
cp bin/* $PREFIX/bin
cp -r ../include/pbbam $PREFIX/include
ls $PREFIX/lib
ls $PREFIX/include