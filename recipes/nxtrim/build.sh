#!/bin/bash
mkdir -p $PREFIX/bin
make LFLAGS="-L$PREFIX/lib -lz"
cp nxtrim $PREFIX/bin
