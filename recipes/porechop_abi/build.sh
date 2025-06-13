#!/bin/bash

if [ $(uname -s) == "Darwin" ]; then
    CXXFLAGS="${CXXFLAGS} -std=c++17 -Dbinary_function=__binary_function -Dunary_function=__unary_function"
else
    CXXFLAGS="${CXXFLAGS} -std=c++17"
fi    

python -m pip install . --ignore-installed --no-deps -vv
