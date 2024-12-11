#!/bin/bash

CXXFLAGS="${CXXFLAGS} -std=c++17"

python -m pip install . --ignore-installed --no-deps -vv
