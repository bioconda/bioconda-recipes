#!/bin/sh

python -m pip install . --no-deps --ignore-installed -vv

export LIBRARY_PATH=$CONDA_PREFIX/lib:$LIBRARY_PAT
export CPATH=$CONDA_PREFIX/include:$CPATH

cd src/RRIkinDP
make -j ${CPU_COUNT}
install RRIkinDP "$CONDA_PREFIX/bin"
