#!/bin/bash
mkdir release && pushd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make VERBOSE=1 -j ${CPU_COUNT}
install -d $PREFIX/bin
install bindash $PREFIX/bin
popd
