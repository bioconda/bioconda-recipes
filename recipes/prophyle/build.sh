#! /usr/bin/env bash

set -e
set -o pipefail

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
make -C prophyle CC="$CC -fcommon -L$PREFIX/lib" CXX="$CXX -L$PREFIX/lib"  # hacky, but the nesting of Makefiles makes it annoying otherwise
PROPHYLE_PACKBIN=1 python -m pip install --no-deps --ignore-installed . 
