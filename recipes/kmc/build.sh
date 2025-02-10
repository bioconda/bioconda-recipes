#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

if [[ "$(uname)" == "Darwin" ]]; then
    mv bin/kmc ${PREFIX}/bin
    mv bin/kmc_tools ${PREFIX}/bin
    mv bin/kmc_dump ${PREFIX}/bin
else
    mv bin/kmc ${PREFIX}/bin
    mv bin/kmc_tools ${PREFIX}/bin
    mv bin/kmc_dump ${PREFIX}/bin
    mv bin/libkmc_core.a ${PREFIX}/lib
    mv include/kmc_runner.h ${PREFIX}/include
fi
