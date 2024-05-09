#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DCIFPP_DOWNLOAD_CCD=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
cmake --build . --config Release
cmake --install . --prefix ${PREFIX}
