#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

if [ "$(uname)" == "Darwin" ]; then    
    mv bin/kmc ${PREFIX}/bin
    mv bin/kmc_tools ${PREFIX}/bin
    mv bin/kmc_dump ${PREFIX}/bin
else
    make CC=${CXX} -j32 all bin/libkmc_api.so
    mv bin/kmc $PREFIX/bin
    mv bin/kmc_tools $PREFIX/bin
    mv bin/kmc_dump $PREFIX/bin
    mv bin/libkmc_core.a $PREFIX/lib
    mv bin/libkmc_api.so $PREFIX/lib/libkmc.so
    mv kmc_api/*.h $PREFIX/include
    mv include/kmc_runner.h $PREFIX/include
fi



