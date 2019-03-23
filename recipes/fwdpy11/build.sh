#!/bin/bash
export GSL_INCLUDE_DIR=${PREFIX}/include
export GSL_LIBRARY=${PREFIX}/lib
export PKG_CONFIG_EXECUTABLE=${PREFIX}/bin
$PYTHON -m pip install . --no-deps --ignore-installed -vv
