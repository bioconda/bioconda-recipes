#!/bin/bash
ls -l  # debug
cmake -Wno-dev -G "Unix Makefiles" -DOPENCL_LIBRARY=${PREFIX}/lib/libOpenCL.so -DOPENCL_INCLUDE_DIR=${PREFIX}/include -DCMAKE_MAKE_PROGRAM=make -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX
make
mkdir -p $PREFIX/bin
cp cas-offinder $PREFIX/bin
