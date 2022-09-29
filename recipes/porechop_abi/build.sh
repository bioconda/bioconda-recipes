#!/bin/bash
export CXXFLAGS="${CXXFLAGS} -std=c++14"
export CPATH=${PREFIX}/include

python -m pip install . --ignore-installed --no-deps -vv