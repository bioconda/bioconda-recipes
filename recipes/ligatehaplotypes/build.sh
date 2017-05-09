#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

sed -i.bak 's/\/usr\/local/${PREFIX}/' makefile
sed -i.bak 's/\/users\/delaneau\/BOOST\/include/${BOOST_INCLUDE_DIR}/' makefile
sed -i.bak 's/~\/BOOST/${BOOST_ROOT_DIR}/g' makefile

make cluster
make install
