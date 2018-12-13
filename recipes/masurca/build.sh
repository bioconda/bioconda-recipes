#!/usr/bin/env bash

set -x -e

export BOOST_ROOT=${PREFIX}
export DEST=${PREFIX}
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include"
export PERL_EXT_LDFLAGS="-shared -O2 -L/usr/local/lib -fstack-protector"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include

./install.sh
