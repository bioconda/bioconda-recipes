#!/bin/sh
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include

if test -d bedtools2; then echo Hoisting prevented by .*; cd bedtools2; fi
make install prefix=$PREFIX CXX=$CXX CC=$CC LDFLAGS="-L$PREFIX/lib" BT_CXXFLAGS=
