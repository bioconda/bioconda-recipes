#!/bin/bash

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
        export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi

curdir=$(pwd)

mkdir -p build
cd build

cmake -DDLIB_NO_GUI_SUPPORT=ON -DBUILD_DIAGNOSTICS=OFF -DBOOST_ROOT="${PREFIX}" -DDLIB_INCLUDEDIR="${curdir}/dlib/" ..
cmake --build . --config Release

mv sciphi "${PREFIX}/bin"
