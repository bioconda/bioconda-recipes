#!/bin/sh

python -m pip install . --no-deps --ignore-installed -vv

cd src/RRIkinDP

CXXFLAGS += -I$(CONDA_PREFIX)/include  # Add Boost include directory
LDFLAGS += -L$(CONDA_PREFIX)/lib       # Add Boost library directory


make -j ${CPU_COUNT}
install RRIkinDP "$CONDA_PREFIX/bin"
