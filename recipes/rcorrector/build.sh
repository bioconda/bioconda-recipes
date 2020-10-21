#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export OBJC_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include 
export LD_LIBRARY_PATH=$PATH/lib:$LD_LIBRARY_PATH
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-Wall -O3 -std=c++0x -L$PREFIX/lib"

sed -i.bak 's/CXXFLAGS=.*//' Makefile

make CXX=$CXX
mkdir -p $PREFIX/bin
cp -R rcorrector run_rcorrector.pl $PREFIX/bin
chmod +x $PREFIX/bin/run_rcorrector.pl
