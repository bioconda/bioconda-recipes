#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
$PYTHON setup.py install
