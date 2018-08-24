#!/bin/bash
make -j
cp $SRC_DIR/mapDIA $PREFIX/bin/mapDIA
chmod +x $PREFIX/bin/mapDIA