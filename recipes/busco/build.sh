#!/bin/bash

set -euxo pipefail

"${PYTHON}" -m pip install . --no-deps -vv

mkdir -p $PREFIX/bin/
cp bin/busco $PREFIX/bin/busco #python script
cp scripts/generate_plot.py $PREFIX/bin/generate_plot.py

