#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
make
mv $SRC_DIR/LightAssembler $PREFIX/bin/LightAssembler