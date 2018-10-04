#!/bin/bash
set -eu

make
make test
mkdir -p ${PREFIX}/bin
chmod a+x sambamba_v*
cp sambamba_v* ${PREFIX}/bin/sambamba
