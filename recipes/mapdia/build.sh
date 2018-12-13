#!/bin/bash
make -j
mkdir -p $PREFIX/bin
cp $SRC_DIR/mapDIA $PREFIX/bin/mapDIA
chmod +x $PREFIX/bin/mapDIA