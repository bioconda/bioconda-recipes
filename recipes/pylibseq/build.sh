#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -ltbb"
#On OS X, we have to force Python 
#packages to compile with GCC.
#Conda setup will default to enforcing 
#clang o/w.
CC=gcc CXX=g++ $PYTHON setup.py install
