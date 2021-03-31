#!/bin/sh
mkdir build
cd build
cmake ..
make
cmake --install . --prefix ${PREFIX}
# TODO: copy python scripts
