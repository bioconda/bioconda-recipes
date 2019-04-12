#!/bin/bash
make install CC=$CC CFLAGS="-O3 -Wall -I$CONDA_PREFIX/include" LIBS="-L$CONDA_PREFIX/lib" prefix=$PREFIX/bin
