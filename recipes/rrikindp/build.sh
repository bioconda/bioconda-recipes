#!/bin/sh

$PYTHON -m pip install . --no-deps --ignore-installed -vv

cd src/rrikindp

make -j ${CPU_COUNT} CXXFLAGS+="-I${CONDA_PREFIX}/include" LDFLAGS+="-L${CONDA_PREFIX}/lib"
install RRIkinDP "${PREFIX}/bin"
