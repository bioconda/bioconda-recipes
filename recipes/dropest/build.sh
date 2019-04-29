#!/bin/bash
# This is only needed on OSX, where we're pulling in cmake 3.14 at the moment
sed -i.bak '6icmake_policy(SET CMP0074 NEW)' CMakeLists.txt

mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=$CXX -DBOOST_ROOT=$PREFIX -DR_ROOT=$PREFIX -DZLIB_ROOT=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX .. && make
make install

cd ../dropestr
R CMD INSTALL --build .
