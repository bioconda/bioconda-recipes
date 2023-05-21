#!/bin/bash
export CPATH=${PREFIX}/include
$PYTHON setup.py install --single-version-externally-managed --record=rec.txt
