#!/bin/bash

set -ex

# Build and install the C++ application
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build build
cmake --install build
