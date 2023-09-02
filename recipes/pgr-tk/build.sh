#!/bin/bash
## TODO: using environmental variables in the libwfa makefile in the future. 
## The current compiler names are hard-coded in the makefile, so we need these symbolic links
ln -sf $CC $PREFIX/bin/gcc
ln -sf $CXX $PREFIX/bin/g++
export PATH=$PREFIX/bin:$PATH

cd pgr-tk
bash build.sh
