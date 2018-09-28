#!/bin/sh
./configure --prefix=$PREFIX --disable-qt

make -j${CPU_COUNT}
make install
