#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin

ln -sf "$CC" "$PREFIX/bin/gcc"
ln -sf "$CXX" "$PREFIX/bin/g++"

./configure.sh
./run_test.sh micro

mv *.py $PREFIX/lib/
