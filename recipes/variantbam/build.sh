#!/bin/bash
set -eu -o pipefail

sed -i.bak 's#I$with_boost#I$with_boost/include#' configure
sed -i.bak 's#L$with_boost/lib#L$with_boost/lib -Wl,-rpath $with_boost/lib#' configure
./configure --prefix=$PREFIX --with-boost=$PREFIX
make
make install
