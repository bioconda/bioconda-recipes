#!/bin/sh

./configure --prefix=${PREFIX} CXXFLAGS="${CXXFLAGS} -Wno-error=unused-result"
make install
