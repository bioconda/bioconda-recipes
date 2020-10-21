#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w qcli/ scripts/*
fi
$PYTHON -m pip install . --ignore-installed --no-deps -vv
