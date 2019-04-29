#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=$CXX -DBOOST_ROOT=$PREFIX -DR_ROOT=$PREFIX -DZLIB_ROOT=$PREFIX .. && make DESTDIR=$PREFIX
make install

cd ../dropestr
R CMD INSTALL --build .
