#!/bin/sh

cd $SRC_DIR

rm -f "src/magic.h"
./configure --prefix=$PREFIX --enable-static --enable-fsect-man5 --disable-silent-rules --disable-dependency-tracking
make
make install
