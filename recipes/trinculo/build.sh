#!/bin/bash

export LIBRARY_PATH=${PREFIX}/lib

if [ `uname` == Darwin ]; then
    g++ -framework Accelerate -Isrc -o bin/trinculo src/trinculo.cpp
else
    g++ -DLINUX -Isrc -o bin/trinculo src/trinculo.cpp -llapack -lpthread
fi

mkdir -p $PREFIX/bin
cp bin/trinculo $PREFIX/bin
