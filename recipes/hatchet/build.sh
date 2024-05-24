#!/bin/bash

set -xe

# Compile Gurobi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo installer -pkg gurobi*_macos_universal2.pkg -target /

    ls -la /Library/
    export GUROBI_HOME=/Library/gurobi*
    mkdir -p $PREFIX/lib
    ls -laR $GUROBI_HOME/
    cp $GUROBI_HOME/mac64/lib/libgurobi*.dylib $PREFIX/lib

elif [[ "$OSTYPE" == "linux"* ]]; then

    export GUROBI_HOME=$(cd gurobi* && pwd)
    mkdir -p $PREFIX/lib
    cp $GUROBI_HOME/*linux64/lib/*.so* $PREFIX/lib
    cp $GUROBI_HOME/*linux64/lib/*.a $PREFIX/lib
    ls -la $PREFIX/lib
fi

export CXXFLAGS="-O3 -pthread -I${PREFIX}/include ${LDFLAGS}"
$PYTHON -m pip install . --no-build-isolation --no-deps -vvv
