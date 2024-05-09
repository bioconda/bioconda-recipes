#!/bin/sh

./configure --prefix=$PREFIX CPPFLAGS=-DUNIXCONSOLE
make -j ${CPU_COUNT}
make install
