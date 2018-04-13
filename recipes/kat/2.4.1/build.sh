#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# fix automake
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/aclocal
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/automake

# fix autoconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate

# Build boost
./build_boost.sh
./autogen.sh
./configure --disable-silent-rules --disable-dependency-tracking --disable-pykat-install --prefix=$PREFIX
make
make install
