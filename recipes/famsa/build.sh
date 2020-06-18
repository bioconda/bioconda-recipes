#!/bin/bash -e
make famsa -j${CPU_COUNT} CC="${CXX}"
install famsa "${PREFIX}/bin"
