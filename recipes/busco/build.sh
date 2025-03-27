#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

mkdir -p $PREFIX/bin/
cp bin/busco $PREFIX/bin/busco  #python script
cp scripts/generate_plot.py $PREFIX/bin/generate_plot.py

