#!/bin/bash

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH

# Build part
qmake
make

# Install part
mkdir -p "${PREFIX}/bin"
if [ "$(uname)" = "Darwin" ]; then
    cp "${SRC_DIR}/gfaviz.app/Contents/MacOS/gfaviz" "${PREFIX}/bin/"
else
    cp "${SRC_DIR}/gfaviz" "${PREFIX}/bin/"
fi
