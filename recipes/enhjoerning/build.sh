#!/bin/bash
set -euxo pipefail

export CC="${CC:-cc}"
export CXX="${CXX:-c++}"
make PREFIX="$PREFIX" CONDA_PREFIX="$PREFIX" CC="$CC" CXX="$CXX"

mkdir -p "$PREFIX/bin"
cp unicorn "$PREFIX/bin/"