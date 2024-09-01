#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

if [ ! -f ${PREFIX}/bin/skDERsum ]; then
    ${CXX} -std=c++11 -o ${PREFIX}/bin/skDERsum src/skDER/skDERsum.cpp
fi

if [ ! -f ${PREFIX}/bin/skDERcore ]; then
    ${CXX} -std=c++11 -o ${PREFIX}/bin/skDERcore src/skDER/skDERcore.cpp
fi

chmod +x ${PREFIX}/bin/skDERcore
chmod +x ${PREFIX}/bin/skDERsum
