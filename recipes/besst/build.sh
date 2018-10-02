#!/bin/bash

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n runBESST
    2to3 -w -n BESST
    2to3 -w -n setup.py
    2to3 -w -n scripts
fi
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
