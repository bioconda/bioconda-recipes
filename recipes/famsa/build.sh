#!/bin/bash -e
make famsa -j${CPU_COUNT}
install -d "${PREFIX}/bin"
install famsa "${PREFIX}/bin"
