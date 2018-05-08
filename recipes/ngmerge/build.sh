#!/bin/bash

make CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib"
make install PREFIX=$PREFIX
