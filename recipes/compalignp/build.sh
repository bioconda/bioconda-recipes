#!/bin/sh

export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"


wget http://www.biophys.uni-duesseldorf.de/bralibase/squid-1.9g.tar.gz
tar -xzf squid-1.9g.tar.gz

pushd squid-1.9g

./configure --prefix=$PREFIX -q
make clean
make
make install

popd

export C_INCLUDE_PATH="squid-1.9g"
export LIBRARY_PATH="squid-1.9g"
make
mv compalignp $PREFIX/bin/
