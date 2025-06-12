#!/bin/bash

set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig"
export M4="${BUILD_PREFIX}/bin/m4"

rm -df freebayes
git clone --recursive https://github.com/tprodanov/freebayes.git

cd freebayes
./compile.sh
cp build/freebayes "${PREFIX}/bin/_parascopy_freebayes"
cd ../

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
