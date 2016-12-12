#! /bin/bash
set -x
set -e

pushd $SRC_DIR
mkdir -p $PREFIX/bin
chmod +x yaggo
cp yaggo $PREFIX/bin
