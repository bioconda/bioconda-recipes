#!/bin/bash

set -xe

export CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=${PREFIX}"
export CMAKE_ARGS="${CMAKE_ARGS} -DINSTALL_CMAKE_DIR=${PREFIX}/share/cmake/Modules"

INSTALL=off BUILD=only_release ./linux_build-egl.bash

cd "build/make_release"
make install
