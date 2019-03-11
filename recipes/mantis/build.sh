#!/bin/bash

# build spydrpick
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release .. # pass -DNH=1 to disable Haswell instructions
make install VERBOSE=1
popd
