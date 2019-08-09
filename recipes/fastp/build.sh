#!/bin/bash
set -eu -o pipefail

make INCLUDE_DIRS="$PREFIX/include" LIBRARY_DIRS="$PREFIX/lib"
make install
