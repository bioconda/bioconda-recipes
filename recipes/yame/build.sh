#!/bin/bash

export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

# Respect the compiler provided by the conda environment
make CC="${CC:-gcc}"

mkdir -p "${PREFIX}/bin"
cp yame "${PREFIX}/bin/"

