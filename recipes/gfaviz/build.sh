#!/bin/bash

#qmake bugfix: qmake fails if there is no g++ executable available, even if QMAKE_CXX is explicitly set
ln -s $CXX $BUILD_PREFIX/bin/g++
export PATH=$BUILD_PREFIX/bin/:$PATH

qmake
make
mkdir -p "${PREFIX}/bin"

#if [ -z ${MACOSX_DEPLOYMENT_TARGET+x} ]; then

# Install part
if [ "$(uname)" = "Darwin" ]; then
    cp "${SRC_DIR}/gfaviz.app/Contents/MacOS/gfaviz" "${PREFIX}/bin/" # [ osx ]
else
    cp "${SRC_DIR}/gfaviz" "${PREFIX}/bin/" # [ linux ]
fi
