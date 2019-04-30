#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=$CXX -DBOOST_ROOT=$PREFIX -DR_ROOT=$PREFIX -DZLIB_ROOT=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX .. && make
make install

cd ../dropestr
R CMD INSTALL --build .
