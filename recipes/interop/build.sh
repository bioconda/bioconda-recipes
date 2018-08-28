#!/bin/bash
version=1.1.4

tar -xzf v${version}.tar.gz
cd interop-${version}

mkdir build
cd build
cmake ../interop
cmake --build .
