#!/bin/bash
set -euo pipefail

# uses random_shuffle which was removed in C++17
export CXXFLAGS="-std=c++11 ${CXXFLAGS}"

export M4=$BUILD_PREFIX/bin/m4

./autogen.sh
./configure --prefix=$PREFIX
#sed -i.bak -e 's/SUBDIRS = cpp perl/SUBDIRS = cpp/' ./src/Makefile
make
make install
