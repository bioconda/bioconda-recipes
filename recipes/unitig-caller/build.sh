#!/bin/bash
export CXXFLAGS="$CXXFLAGS -std=c++20"
$PYTHON -m pip install . --ignore-installed --no-deps -vv
