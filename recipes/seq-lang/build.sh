#!/bin/bash

./scripts/deps.sh 2 

mkdir build
(cd build && cmake .. -DCMAKE_BUILD_TYPE=Release \
                      -DSEQ_DEP=/path/to/deps \
                      -DCMAKE_C_COMPILER=clang \
                      -DCMAKE_CXX_COMPILER=clang++)
cmake --build build --config Release
