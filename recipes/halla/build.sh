#!/bin/bash

PY3_BUILD="${PY_VER%.*}"

if [ $PY3_BUILD -eq 3 ]; then
    for i in halla/*.py; do
        2to3 -w -n $i
    done
fi

$PYTHON -m pip install . --no-deps --ignore-installed -vv
