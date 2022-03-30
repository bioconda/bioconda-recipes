#!/bin/sh
set -ex
./configure --prefix=$PREFIX --with-vrna=$PREFIX --vrna-libs="-L$PREFIX/lib -lRNA -lpthread"
make -j ${CPU_COUNT}
make install
