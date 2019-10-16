#!/bin/bash

# wrong version string: https://github.com/marbl/Mash/issues/124
sed -i.bak 's/2.2/2.2.1/' src/mash/version.h

./bootstrap.sh
./configure --with-capnp=$PREFIX --with-gsl=$PREFIX --prefix=$PREFIX
make
make install
