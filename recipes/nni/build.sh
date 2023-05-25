#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export PATH="${PATH}:${PREFIX}/.local/bin"

${PYTHON} setup.py develop
