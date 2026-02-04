#!/bin/bash -euo

mkdir -p ${PREFIX}/bin
chmod +x *.pl && cp -f *.pl ${PREFIX}/bin

# Install data
mkdir -p ${PREFIX}/share/vcf2maf/data
cp -r data/* ${PREFIX}/share/vcf2maf/data/

# Symlink data directory into bin
ln -s ../share/vcf2maf/data ${PREFIX}/bin/data
