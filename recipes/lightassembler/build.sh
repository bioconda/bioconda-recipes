#!/bin/bash
export CPATH=${PREFIX}/include
make
mv $SRC_DIR/LightAssembler $PREFIX/bin/LightAssembler