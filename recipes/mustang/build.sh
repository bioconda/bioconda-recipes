#!/bin/bash

mkdir -p $PREFIX/bin
make -j"${CPU_COUNT}"

install -v -m 0755 $SRC_DIR/bin/mustang-$PKG_VERSION $PREFIX/bin
mv $PREFIX/bin/mustang-$PKG_VERSION $PREFIX/bin/mustang
