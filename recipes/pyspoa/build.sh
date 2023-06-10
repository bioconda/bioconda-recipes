#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"

make CXX="${CXX}" INCLUDES="-I${PREFIX}/include" LIBPATH="-L${PREFIX}/lib" build
${PYTHON} -m pip install . --no-deps --ignore-install -vv
