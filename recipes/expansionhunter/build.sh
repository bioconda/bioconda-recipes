#!/bin/bash
mkdir build
cd build
cmake ..
make
mkdir -p $PREFIX/bin
cp install/bin/ExpansionHunter $PREFIX/bin
mkdir -p $PREFIX/share/ExpansionHunter/variant_catalog
cp ../variant_catalog/hg38/variant_catalog.json $PREFIX/share/ExpansionHunter/variant_catalog/variant_catalog_GRCh38.json
