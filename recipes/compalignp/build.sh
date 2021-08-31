#!/bin/sh

pushd squid

./configure --prefix=$PREFIX -q
make clean
make
make install

popd

make CC="${CC}" CFLAGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
mv compalignp $PREFIX/bin/
