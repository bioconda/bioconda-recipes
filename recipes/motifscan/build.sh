#!/bin/bash
export CC=$CXX
export LDSHARED=$CXX
$PYTHON -m pip install . --no-deps --ignore-installed -vv
