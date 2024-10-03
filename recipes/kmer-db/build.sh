#!/bin/bash

uname_S=`uname -s 2>/dev/null || echo not`
if [ "$uname_S" == "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is required but not installed. Please install Homebrew first."
        exit 1
    fi
    if ! brew install gcc@12; then
        echo "Failed to install gcc@12. Please check your Homebrew installation and permissions."
        exit 1
    fi
fi

CFLAGS="$CFLAGS -I${PREFIX}/include"
LDFLAGS="$LDFLAGS -L${PREFIX}/lib"

make -j${CPU_COUNT} CXX=g++-12
install -d "${PREFIX}/bin"
install  kmer-db "${PREFIX}/bin"
