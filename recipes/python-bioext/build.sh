#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

export FREETYPE2_ROOT=$PREFIX

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
