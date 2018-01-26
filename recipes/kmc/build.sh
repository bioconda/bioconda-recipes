#!/bin/bash

export DISABLE_ASMLIB=true
export CXX=g++
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

if [ "$(uname)" == "Darwin" ]; then
    Makefile=makefile_mac
else
    Makefile=makefile
fi
make -f $Makefile

cp bin/kmc bin/kmc_dump bin/kmc_tools "${PREFIX}/bin/"
