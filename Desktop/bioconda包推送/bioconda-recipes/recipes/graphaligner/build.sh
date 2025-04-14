#!/usr/bin/env bash

cd $SRC_DIR
make bin/GraphAligner
cp bin/GraphAligner $PREFIX/bin
