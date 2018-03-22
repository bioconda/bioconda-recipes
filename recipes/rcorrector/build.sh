#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export OBJC_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include 
LD_LIBRARY_PATH=$PATH/lib


make
mkdir -p $PREFIX/bin
cp -R rcorrector run_rcorrector.pl $PREFIX/bin