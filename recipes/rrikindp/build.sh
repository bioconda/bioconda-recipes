#!/bin/sh

cd src/RRIkinDP
make -j ${CPU_COUNT}
install RRIkinDP "$CONDA_PREFIX/bin"

python -m pip install . --no-deps --ignore-installed -vv
