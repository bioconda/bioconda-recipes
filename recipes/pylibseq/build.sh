#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -ltbb"

#On OS X, we have to force Python 
#packages to compile with GCC.
#Conda setup will default to enforcing 
#clang o/w.
CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" $PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
