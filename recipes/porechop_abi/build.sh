#!/bin/bash
export CXXFLAGS="${CXXFLAGS} -std=c++14"
python3 -m pip install . --ignore-installed --no-deps -vv
