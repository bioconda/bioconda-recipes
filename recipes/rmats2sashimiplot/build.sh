#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n src
fi

$PYTHON -m pip install . --ignore-installed --no-deps -vv
