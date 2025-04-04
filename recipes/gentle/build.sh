#!/bin/sh
set -ex
aclocal
libtoolize --automake --force --copy
automake --add-missing
autoconf
mkdir -p ${PREFIX}

./configure --prefix=$PREFIX CXXFLAGS="-I${PREFIX}/include"
make
make install
