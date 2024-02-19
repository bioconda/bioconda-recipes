#!/bin/sh

python -m pip install . --no-deps --ignore-installed -vv

cd src/RRIkinDP
make -j ${CPU_COUNT}
install RRIkinDP "$CONDA_PREFIX/bin"
