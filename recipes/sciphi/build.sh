#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
    grep -r no_warning_for
fi

curdir=$(pwd)

mkdir -p build
cd build

cmake -DCMAKE_VERBOSE_MAKEFILE=ON -DDLIB_NO_GUI_SUPPORT=ON -DBUILD_DIAGNOSTICS=OFF -DBOOST_ROOT="${PREFIX}" -DDLIB_INCLUDEDIR="${curdir}/dlib/" ..
cmake --build . --config Release

mv sciphi "${PREFIX}/bin"
