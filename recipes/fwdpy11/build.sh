#!/bin/bash

export CFLAGS="-I${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CC=gcc
export CXX=g++
$PYTHON setup.py install --gcc
