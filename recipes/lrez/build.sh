#!/bin/bash

export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib/

make -j"${CPU_COUNT}"
make install
