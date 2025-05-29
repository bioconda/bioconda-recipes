#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

mkdir -p $PREFIX/bin
install -v -m 0755 bin/busco $PREFIX/bin  #python script
cp -f scripts/generate_plot.py $PREFIX/bin/generate_plot.py
