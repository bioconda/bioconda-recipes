#!/bin/bash
set -ex

df -h

# Install additional dependencies
wget https://github.com/PLAST-software/plast-library/releases/download/v2.3.2/plastbinary_linux_v2.3.2.tar.gz
echo "PLAST downloaded successfully"

# Setup PLAST binaries
tar -zxf plastbinary_linux_v2.3.2.tar.gz
cp plastbinary_linux_v2.3.2/plast $PREFIX/bin/

# Clone acc2tax repository
git clone https://github.com/richardmleggett/acc2tax.git
echo "acc2tax downloaded successfully"

# Build acc2tax
cd acc2tax
# According to https://bioconda.github.io/contributor/troubleshooting.html
# and https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
$(which "$CC") -o acc2tax acc2tax.c
cp acc2tax $PREFIX/bin/
cd ..

chmod +x $PREFIX/bin/plast
chmod +x $PREFIX/bin/acc2tax

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

df -h