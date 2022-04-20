#!/usr/bin/env bash

set -x -e
BOOST_ROOT=${PREFIX}
export DEST=${PREFIX}
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O2 -fstack-protector"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -std=gnu90"
export CXXFLAGS="$CXXFLAGS -std=gnu++14"
./install.sh
