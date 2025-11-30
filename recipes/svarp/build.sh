#!/bin/bash
set -ex

cd "$SRC_DIR"

make clean || true

echo "PREFIX is $PREFIX"
echo "Listing headers under $PREFIX/include:"
ls -R "$PREFIX/include"

make USE_CONDA=1 PREFIX="$PREFIX" -j"${CPU_COUNT}"

mkdir -p "$PREFIX/bin"
cp build/svarp "$PREFIX/bin/"
