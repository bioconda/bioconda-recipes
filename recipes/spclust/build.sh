#!/bin/bash
export CXX=mpicxx
./configure --prefix=$PREFIX
make
make install
