#!/bin/bash

sed -i.bak "s#gcc#$CC#g" src/lagan/src/Makefile
sed -i.bak "s#g++#$CXX#g" src/lagan/src/Makefile
sed -i.bak "s#gcc#$CC#g" src/lagan/src/glocal/Makefile
sed -i.bak "s#g++#$CXX#g" src/lagan/src/glocal/Makefile
cd build
cmake ../src -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_CC_COMPILER=$CC
make
make install
