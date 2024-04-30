#!/usr/bin/env bash

set -xe

cd $SRC_DIR
make -j ${CPU_COUNT} bin/GraphAligner
cp bin/GraphAligner $PREFIX/bin
