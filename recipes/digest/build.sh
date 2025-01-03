#!/bin/bash

BUILD_DIR="${SRC_DIR}/build"

meson setup --prefix=${PREFIX} --buildtype=release "${BUILD_DIR}"
meson install -C "${BUILD_DIR}"
$CXX -O3 -Wall -shared -std=c++17 -fPIC $(python3 -m pybind11 --includes) \
    -I${SRC_DIR}/pybind \
    -I${SRC_DIR}/include \
    -I${PREFIX}/include \
    -L${PREFIX}/lib \
    pybind/bindings.cpp \
    -o ${PREFIX}/digest$(python3-config --extension-suffix)

cp ${PREFIX}/digest$(python3-config --extension-suffix) ${SP_DIR}
touch ${SP_DIR}/__init__.py