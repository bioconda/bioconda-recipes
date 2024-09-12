#!/usr/bin/bash
export CXXFLAGS="${CXXFLAGS} -I$SRC_DIR/src"
$PYTHON -m pip install . --ignore-installed --no-deps --no-cache-dir -vvv
