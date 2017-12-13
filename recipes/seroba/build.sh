#!/bin/bash

# We don't have a compiler on Conda for C++14, so downloading pre-compiled binary and moving to bin.
wget https://github.com/refresh-bio/KMC/releases/download/v3.0.0/KMC3.linux.tar.gz
tar xzf KMC3.linux.tar.gz

chmod 755 kmc
chmod 755 kmc_tools
chmod 755 kmc_dump

cp kmc $PREFIX/bin
cp kmc_tools $PREFIX/bin
cp kmc_dump $PREFIX/bin

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
