#!/bin/bash


export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib -L3rd/libsvm"
export CPPFLAGS="-I${PREFIX}/include -I3rd/libsvm"

python setup.py build_ext --with-libsvm \
     ${LDFLAGS} ${CPPFLAGS} -lsvm

python setup.py install --with-libsvm
