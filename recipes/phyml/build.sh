#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# For some reason, without this patch compilation fails in OSX. BEAGLE is not
# used in the default compilation.
patch configure.ac $RECIPE_DIR/phyml.patch

/bin/sh autogen.sh
./configure
make

mkdir -p $PREFIX/bin
cp src/phyml $PREFIX/bin
