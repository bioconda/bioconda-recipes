#!/bin/sh
./configure --prefix=$PREFIX --with-vrna=$PREFIX

## libstdc++ is expected in lib64, so link it there
ln -s $PREFIX/lib/libstdc++.la $PREFIX/lib64/libstdc++.la 
ln -s $PREFIX/lib/libstdc++.so $PREFIX/lib64/libstdc++.so 

make -j4
make install
