#!/usr/bin/env bash

cd $SRC_DIR
ls -la $PREFIX/lib/
echo $LIBRARY_PATH
export LIBRARY_PATH=$PREFIX/lib
echo $LIBRARY_PATH
make bin/GraphAligner
cp bin/GraphAligner $PREFIX/bin
