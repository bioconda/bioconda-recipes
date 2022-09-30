#!/bin/bash

mkdir -p $PREFIX/bin/

cd merger
make clean
make CC=$CXX CFLAGS="$CXXFLAGS"

cp quickmerge ../merge_wrapper.py $PREFIX/bin/

chmod +x $PREFIX/bin/quickmerge
chmod +x $PREFIX/bin/merge_wrapper.py
