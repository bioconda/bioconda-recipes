#!/bin/bash

set -xe

export CFLAGS="-O2 -fomit-frame-pointer -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O2 -fomit-frame-pointer -I$PREFIX/include $CXXFLAGS"

case $(uname) in
    Darwin) 
        CONFIGURE_FLAGS="--disable-asm" # see https://github.com/ckolivas/lrzip/pull/204#issuecomment-874298957
        ;;
    *)
        CONFIGURE_FLAGS=""
        ;;
esac

./autogen.sh
./configure --prefix=$PREFIX ${CONFIGURE_FLAGS}
make --jobs=${CPU_COUNT}
make install

