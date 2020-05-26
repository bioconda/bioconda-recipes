#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

make modules
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing GraphMap for OSX."
    make mac GCC=$CXX GCC_MAC=$CXX
    cp bin/Mac/graphmap $PREFIX/bin/graphmap2
else
    echo "Installing GraphMap for UNIX/Linux."
    make GCC=$CXX LD_FLAGS="$LDFLAGS -static-libgcc -static-libstdc++ -m64 -ffreestanding"
    cp bin/Linux-x64/graphmap2 $PREFIX/bin
fi
