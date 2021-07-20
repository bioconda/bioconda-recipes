#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

#Check gcc is present
echo $CC

sed -E -i.bak \
    -e 's/gcc/$CC/' \
    ./scripts/deps.sh


./scripts/deps.sh 2 

mkdir build
(cd build && cmake .. -DCMAKE_BUILD_TYPE=Release \
                      -DSEQ_DEP=/path/to/deps \
                      -DCMAKE_C_COMPILER=clang \
                      -DCMAKE_CXX_COMPILER=clang++)
cmake --build build --config Release
