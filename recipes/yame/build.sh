#!/bin/bash

# Respect the compiler provided by the conda environment
make CC="${CC:-gcc}"

mkdir -p "${PREFIX}/bin"
cp yame "${PREFIX}/bin/"

