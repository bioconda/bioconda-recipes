#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
$PYTHON setup.py install
# run tests here
$PYTHON -m nose -v pysamstats
pysamstats --help

