#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
$PYTHON setup.py install
# run tests here
$PYTHON setup.py build_ext --inplace
$PYTHON -m nose -v pysamstats
