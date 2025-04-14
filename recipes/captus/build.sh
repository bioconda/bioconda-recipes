#!/bin/bash

if [[ `uname -s` == "Linux" ]];
then
    ln -sf "${PREFIX}/lib/libbz2.so.1.0" "${PREFIX}/lib/libbz2.so.1"
fi

$PYTHON -m pip install . --no-build-isolation --no-cache-dir --no-build-isolation -vvv
