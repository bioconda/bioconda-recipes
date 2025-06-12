#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

export LDFLAGS=
${CXX} -std=c++11 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/skDERsum src/skDER/skDERsum.cpp
${CXX} -std=c++11 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/skDERcore src/skDER/skDERcore.cpp

chmod +x ${PREFIX}/bin/skDERcore
chmod +x ${PREFIX}/bin/skDERsum
