#!/bin/bash

set -xe

mkdir build
cd build
cmake ..
make -j ${CPU_COUNT}
mkdir -p $PREFIX/bin
cp install/bin/ExpansionHunter $PREFIX/bin
mkdir -p $PREFIX/share/ExpansionHunter
cp -R ../variant_catalog $PREFIX/share/ExpansionHunter
chmod a-x $PREFIX/share/ExpansionHunter/variant_catalog/*/*json
