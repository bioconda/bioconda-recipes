#!/bin/bash

mkdir build
cd build

# Require 10.12 SDK for SeqAN's use of std::shared_timed_mutex
export MACOSX_DEPLOYMENT_TARGET=10.12
cmake \
    -DCMAKE_CXX_STANDARD=14 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DSLIMM_NATIVE_BUILD=OFF \
    ..
make
make install

# TODO: Remove lines below if source-based build works on macOS.
#mkdir -p "${PREFIX}/bin"
#cp bin/* "${PREFIX}/bin/"
#cp -r share/* "${PREFIX}/share/"
