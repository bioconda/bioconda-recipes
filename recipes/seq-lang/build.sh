#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

# add gcc link
cc_path=$(which ${CC})
ln -s $cc_path ${PREFIX}/bin/gcc

#check it works
gcc --version

sed -E -i.bak \
    -e 's/gcc/$CC/' \
    ./scripts/deps.sh

echo "running deps.sh"

./scripts/deps.sh 2 

echo "deps.sh done"

mkdir build
cd build 
cmake .. -DCMAKE_BUILD_TYPE=Release \
                      -DSEQ_DEP=../deps \
                      -DCMAKE_C_COMPILER=${CC} \
                      -DCMAKE_CXX_COMPILER=${CXX}

cmake --build build --config Release
