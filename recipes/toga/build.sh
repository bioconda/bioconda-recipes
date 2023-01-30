#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin

./configure.sh
./run_test.sh micro

mv *.py $PREFIX/lib/
