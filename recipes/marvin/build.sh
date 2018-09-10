#! /bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make

cp marvin $PREFIX/bin/
cp marvin_prep $PREFIX/bin/
chmod +x $PREFIX/bin/marvin
chmod +x $PREFIX/bin/marvin_prep