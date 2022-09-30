#!/bin/bash
./configure --prefix=$PREFIX
make install
cp $PREFIX/bin/ParaFly $PREFIX
