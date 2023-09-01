#!/bin/sh
set -ex
aclocal
libtoolize --automake --force --copy
automake --add-missing
autoconf
mkdir -p ${PREFIX}
echo "CXX: $CXX"
if [ "x$CXX" = "x" ]; then
  #export CXX="g++"
  echo "CXX found empty, set to '$CXX'"
fi
echo "CXXFLAGS: ${CXXFLAGS}"
echo "LDFLAGS: ${LDFLAGS}"
echo "PREFIX: ${PREFIX}"
echo "PATH: ${PATH}"
echo "which g++:"
if ! which g++ > /dev/null; then
  echo "g++ not in path"
  #echo " installing it via conda"
  #conda install gxx
fi
echo "which gcc:"
which gcc || echo "gcc not in path"
echo "which clang:"
which clang || echo "clang not in path"
./configure --prefix=$PREFIX CXXFLAGS="-I${PREFIX}/include"
make
make install
