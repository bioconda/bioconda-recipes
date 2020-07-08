#!/bin/bash

chmod 755 ./configure
./configure --prefix=$PREFIX
make
mv LDBlockShow $PREFIX/bin/LDBlockShow
ln -s $PREFIX/bin/LDBlockShow $PREFIX/bin/ldblockshow
