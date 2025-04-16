#!/bin/bash

export CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=${PREFIX}"
INSTALL=off BUILD=only_release ./linux_build-egl.bash

cd "build/make_release"
make install
