#!/bin/bash

mkdir build
cd build
echo $PREFIX
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_VERBOSE_MAKEFILE=ON ..
make -j ${CPU_COUNT} ${VERBOSE_CM}
make install

# Debug: List contents of $PREFIX
echo "Contents of $PREFIX:"
ls -R $PREFIX