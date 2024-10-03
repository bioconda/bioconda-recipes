#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

#export LDFLAGS=
# -Wl,-headerpad_max_install_names
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERsum src/skDER/skDERsum.cpp
${CXX} -std=c++11 -o ${PREFIX}/bin/skDERcore src/skDER/skDERcore.cpp

chmod +x ${PREFIX}/bin/skDERcore
chmod +x ${PREFIX}/bin/skDERsum
