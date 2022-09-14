#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

bash build.sh -l $LIBRARY_PATH
cp -r hapog.py lib build ${PREFIX}/bin
