#!/bin/bash
CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
#LD_LIBRARY_PATH is used to link unit tests to libsequence runtime lib,
#allowing us to run tests here.  Attempting to run tests from tests: 
#block of yaml fails, presumably b/c pwd has changed by that point.
export LD_LIBRARY_PATH=$PREFIX/lib
make check
make install

