#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

# (re)-compile RBH/InParanoid-esque programs written in C++
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERcore skDERcore.cpp
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERsum skDERsum.cpp

chmod +x ${PREFIX}/bin/skDERcore
chmod +x ${PREFIX}/bin/skDERsum
