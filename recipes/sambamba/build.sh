#!/bin/bash
set -eu

# Install sambamba from source
make
mkdir -p $PREFIX/bin
chmod a+x sambamba*
cp sambamba* $PREFIX/bin/sambamba
