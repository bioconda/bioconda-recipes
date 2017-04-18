#!/bin/bash

export PKG_CONFIG_PATH="$PREFIX/share/pkgconfig:$PREFIX/lib/pkgconfig"
export ACLOCAL_FLAGS="-I$PREFIX/share/aclocal"
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./autogen.sh --prefix=$PREFIX --with-internal-glib --with-python=/opt/miniconda3/bin/python
./configure --prefix=$PREFIX --with-internal-glib --with-python=/opt/miniconda3/bin/python
make
make install

