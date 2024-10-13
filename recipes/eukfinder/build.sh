#!/bin/bash
set -ex
mkdir -p ${PREFIX}/bin
# Setup PLAST binaries
cp build/bin/plast $PREFIX/bin/

# Build acc2tax
# According to https://bioconda.github.io/contributor/troubleshooting.html
# and https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
$CC -o acc2tax acc2tax.c
cp acc2tax $PREFIX/bin/

chmod +x $PREFIX/bin/plast
chmod +x $PREFIX/bin/acc2tax

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
