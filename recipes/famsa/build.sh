#!/bin/bash -e
make famsa -j${CPU_COUNT} CC="${CXX}"
install -d "${PREFIX}/bin"
install famsa "${PREFIX}/bin"
