#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    make no_omp
else
    make
fi
cp akt $PREFIX/bin
