#!/bin/bash -e
make famsa -j${CPU_COUNT} NO_GPU=true CC="${CXX}"
install famsa "${PREFIX}/bin"
