#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export OBJC_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include 
export LD_LIBRARY_PATH=$PATH/lib:$LD_LIBRARY_PATH
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make
mkdir -p $PREFIX/bin
cp -R rcorrector run_rcorrector.pl $PREFIX/bin
chmod -x $PREFIX/bin/run_rcorrector.pl
