#!/bin/bash

mkdir -p  "$PREFIX/bin"

ls -l
cmake .
make

cp shannon_cpp $PREFIX/bin/
cp syrupy.py $PREFIX/bin/
cp run_rcorrector.pl $PREFIX/bin/

