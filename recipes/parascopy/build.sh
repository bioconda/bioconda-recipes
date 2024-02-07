#!/bin/bash

rm -df freebayes
git clone --recursive https://github.com/tprodanov/freebayes.git

cd freebayes
mkdir build
meson build/ --buildtype release
cd build
ninja -v
cp freebayes "${PREFIX}/bin/_parascopy_freebayes"
cd ../../

$PYTHON -m pip install . --no-build-isolation --no-deps -vvv
