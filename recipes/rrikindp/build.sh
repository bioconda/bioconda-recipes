#!/bin/sh

python -m pip install . --no-deps --ignore-installed -vv

cd src/RRIkinDP

make -j ${CPU_COUNT} CXXFLAGS+="-I$(CONDA_PREFIX)/include" LDFLAGS+="-L$(CONDA_PREFIX)/lib"
install RRIkinDP "$CONDA_PREFIX/bin"
