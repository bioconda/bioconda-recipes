#!/bin/bash
make -j${CPU_COUNT} CXX=g++-11 LEIDEN=true
install -d "${PREFIX}/bin"
install clusty "${PREFIX}/bin"
