#!/bin/sh
env | sort
./configure --prefix=$PREFIX --with-vrna=$PREFIX
make -j ${CPU_COUNT}
make install
