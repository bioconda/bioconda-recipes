#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export M4="${BUILD_PREFIX}/bin/m4"

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
