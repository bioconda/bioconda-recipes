#!/bin/bash

mkdir -p ${PREFIX}/bin/

# set variables for zlib
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

# create executables
make

cp utils/matcher ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/matcher
cp utils/phist ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/phist
cp phist.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/phist.py
