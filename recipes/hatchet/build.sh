#!/bin/bash

set -xe

# Compile Gurobi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo installer -pkg gurobi*_macos_universal2.pkg -target /

    export GUROBI_HOME=/Library/gurobi*
    mkdir -p $PREFIX/lib
    cp $GUROBI_HOME/mac64/lib/libgurobi*.dylib $PREFIX/lib

else

    # Gurobi Makefile uses a variable called 'C++'
    # Rename this inline to 'CPP' so we can override it with the correct compiler on 'make'
    sed -i 's/C++/CPP/g' gurobi*/*linux64/src/build/Makefile
    (cd gurobi*/*linux64/src/build && make -j ${CPU_COUNT} CPP=${CXX})
    (cd gurobi*/*linux64/lib && ln -f -s ../src/build/libgurobi_c++.a libgurobi_c++.a)

    export GUROBI_HOME=$(cd gurobi* && pwd)
    mkdir -p $PREFIX/lib
    cp $GUROBI_HOME/*linux64/lib/libgurobi*.so $PREFIX/lib
fi

export CXXFLAGS="-O3 -pthread -I${PREFIX}/include ${LDFLAGS}"
$PYTHON -m pip install . --no-build-isolation --no-deps -vvv
