#!/bin/bash
curdir=$(pwd)

mkdir -p build
cd build

cmake -DCMAKE_VERBOSE_MAKEFILE=ON -DDLIB_NO_GUI_SUPPORT=ON -DBUILD_DIAGNOSTICS=OFF -DBOOST_ROOT="${PREFIX}" -DDLIB_INCLUDEDIR="${curdir}/dlib/" ..
cmake --build . --config Release

mv sciphin "${PREFIX}/bin"
