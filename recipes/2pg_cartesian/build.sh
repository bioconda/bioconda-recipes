#!/bin/bash
sed -i 's/\-lm \-pedantic/\-lm \-pedantic \-fpermissive/g' CMakeLists.txt
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
