#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak 's/\/usr\/local/${PREFIX}/' makefile
sed -i.bak 's/\/users\/delaneau\/BOOST/${PREFIX}/' makefile
sed -i.bak 's/~\/BOOST/${PREFIX}/g' makefile

make cluster
make install
