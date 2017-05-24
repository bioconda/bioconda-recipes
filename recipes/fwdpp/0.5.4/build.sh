#!/bin/bash
CPPFLAGS="-I$PREFIX/include $CPPFLAGS" LDFLAGS="-L$PREFIX/lib $LDFLAGS" ./configure --prefix=$PREFIX
make
#LD_LIBRARY_PATH is used to link unit tests to libsequence runtime lib,
#allowing us to run tests here.  Attempting to run tests from tests: 
#block of yaml fails, presumably b/c pwd has changed by that point.
export LD_LIBRARY_PATH=$PREFIX/lib
if [ `uname` == 'Linux' ]; then make check; fi
if [ `uname` == 'Darwin' ]; then cd test; for i in $(find testsuite -type f -perm +111|grep -v integration); do $i -r detailed; done; cd ..;fi
make install

