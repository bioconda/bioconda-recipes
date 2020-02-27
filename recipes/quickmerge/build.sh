#!/bin/bash

mkdir -p $PREFIX/bin/

cd merger
make clean
make

cp merge_wrapper.py $PREFIX/bin/

chmod +x $PREFIX/bin/quickmerge
chmod +x $PREFIX/bin/merge_wrapper.py