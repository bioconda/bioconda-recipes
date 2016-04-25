#!/bin/bash

./configure --prefix=$PREFIX 
make
#ls 
#mv bin $PREFIX/bin
#mv include $PREFIX/include
#mv lib $PREFIX/lib
#mv share $PREFIX/share
make install

