#!/bin/sh

wget http://www.biophys.uni-duesseldorf.de/bralibase/squid-1.9g.tar.gz
tar -xzf squid-1.9g.tar.gz
cd squid-1.9g

./configure --prefix=$PREFIX -q
make clean
make
make install

cd ..

export CFLAGS="-I$PREFIX/include -L$PREFIX/lib"

make
cp compalignp $PREFIX/bin