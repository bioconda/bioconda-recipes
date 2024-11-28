#!/bin/bash

if [ `uname -s` == "Linux" ];
then
    ln -s "${PREFIX}/lib/libbz2.so.1.0" "${PREFIX}/lib/libbz2.so.1"
fi

$PYTHON -m pip install . --ignore-installed -vv
