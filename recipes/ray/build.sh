#!/bin/bash

mkdir -p $PREFIX/bin
export MPICXX=$PREFIX/bin
make 
make install
chmod +x Ray
cp Ray $PREFIX/bin
ls $PREFIX
