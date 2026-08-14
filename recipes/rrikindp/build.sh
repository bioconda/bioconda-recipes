#!/bin/bash
set -xe

# the command line tool is not installed by pip and is built separately
make -C src/rrikindp -j"${CPU_COUNT}" CXXFLAGS="${CXXFLAGS} -O3"
install -D -m 0755 src/rrikindp/RRIkinDP "${PREFIX}/bin/RRIkinDP"

# the python module, including the pybind11 extension
CXXFLAGS="${CXXFLAGS} -O3" ${PYTHON} -m pip install . \
    --no-deps --no-build-isolation --no-cache-dir -vv

