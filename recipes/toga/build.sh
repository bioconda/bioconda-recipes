#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin

ln  "$CC" "$PREFIX/bin/gcc"
ln  "$CXX" "$PREFIX/bin/g++"

./configure.sh

mv *.py $PREFIX/bin/
mv *.sh $PREFIX/bin/
