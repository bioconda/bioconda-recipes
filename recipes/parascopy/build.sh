#!/bin/bash

export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig

rm -df freebayes
git clone --recursive https://github.com/tprodanov/freebayes.git

cd freebayes
./compile.sh
cp build/freebayes "${PREFIX}/bin/_parascopy_freebayes"
cd ../

$PYTHON -m pip install . --no-build-isolation --no-deps -vvv
