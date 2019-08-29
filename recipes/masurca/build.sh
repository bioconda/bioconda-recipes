#!/usr/bin/env bash

set -x -e

export BOOST_ROOT=${PREFIX}
export DEST=${PREFIX}
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O2 -fstack-protector"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include
# C++17 breaks the Celera Assembler build, so force C++11 by adding the flag last
export CXXFLAGS="$CXXFLAGS -std=c++11"
sed -i.bak "s#-lz#-L${PREFIX}/lib -lz#g" Flye/lib/minimap2/Makefile

./install.sh
