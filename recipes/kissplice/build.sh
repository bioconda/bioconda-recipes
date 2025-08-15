#!/bin/bash

cmake -S . -B build/ -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build build/
cmake --install build/
