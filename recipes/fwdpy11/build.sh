#!/bin/bash
export GSL_INCLUDE_DIR=${PREFIX}/include
export GSL_LIBRARY=${PREFIX}/lib
export PATH="${PREFIX}/bin:$PATH"
$PYTHON -m pip install . --no-deps --ignore-installed -vv
