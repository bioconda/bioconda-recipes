#!/bin/sh

export CFLAGS="-I${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -L${PREFIX}/include -lintl"

cd "$SRC_DIR"
make
make install prefix=$PREFIX

# rename to prevent collision with system (BSD) getopt on OSX
mv $PREFIX/bin/getopt $PREFIX/bin/gnu-getopt