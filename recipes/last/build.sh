#!/bin/bash

if [[ $(uname) == "Darwin" ]]
then
    export CMAKE_CXX_FLAGS="-stdlib=libc++"
fi

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -w -n `grep -l python ${SRC_DIR}/scripts/*`
fi

cp ${SRC_DIR}/scripts/* ${PREFIX}/bin/
make install CXX="${CXX} $CMAKE_CXX_FLAGS -I$PREFIX/include -L$PREFIX/lib" prefix=${PREFIX}
chmod +x ${PREFIX}/bin/*
