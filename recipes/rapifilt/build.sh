#!/bin/bash
echo "rapifilt compilation"

make CPP=${CXX} CC=$CC PPFLAGS="-I${PREFIX}/include" LFLAGS="-L${PREFIX}/lib"

mkdir -p $PREFIX/bin
cp rapifilt $PREFIX/bin
echo "Installation successful"
