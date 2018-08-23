#!/bin/bash
make
mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/mustang-3.2.3 $PREFIX/bin/mustang
chmod +x $PREFIX/bin/mustang