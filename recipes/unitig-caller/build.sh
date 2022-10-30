#!/bin/bash
export CXXFLAGS="$CXXFLAGS -std=c++20"
export UC_INSTALL="conda"
$PYTHON -m pip install . --ignore-installed --no-deps -vv
