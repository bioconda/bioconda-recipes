#!/bin/bash
set -eu -o pipefail
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

sed -i.bak 's#I$with_boost#I$with_boost/include#' configure
sed -i.bak 's#L$with_boost/lib#L$with_boost/lib -Wl,-rpath $with_boost/lib#' configure
./configure --prefix=$PREFIX --with-boost=$PREFIX
make
make install
