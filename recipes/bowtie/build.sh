#!/bin/bash

if [ $(uname) == "Darwin" ]; then
    CXXFLAGS="$CXXFLAGS -I$(xcrun --show-sdk-path)/usr/include"
    LDFLAGS="$LDFLAGS -L$(xcrun --show-sdk-path)/usr/lib"
fi

make && make install prefix=$PREFIX

PY3_BUILD="${PY_VER%.*}"

PYTHON_FILES="bowtie bowtie-build bowtie-inspect"

if [ $PY3_BUILD -eq 3 ]; then
    for i in $PYTHON_FILES; do 2to3 --write $i; done
fi
