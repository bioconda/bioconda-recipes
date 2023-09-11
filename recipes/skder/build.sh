#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

# (re)-compile C++ programs
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERcore skDERcore.cpp
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERsum skDERsum.cpp

chmod +x ${PREFIX}/bin/skDERcore
chmod +x ${PREFIX}/bin/skDERsum
