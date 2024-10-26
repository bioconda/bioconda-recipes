#!/bin/bash

unset LD LINK ARCH
export CMAKE_INSTALL_RPATH='$ORIGIN/../lib'
export CMAKE_BUILD_WITH_INSTALL_RPATH=ON

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/share"
mkdir -p $SRC_DIR/build
cd $SRC_DIR/build || exit 1

cmake -S $SRC_DIR -B $SRC_DIR/build  \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_MODULE_PATH=$PREFIX/share/cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_RPATH=$CMAKE_INSTALL_RPATH \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=$CMAKE_BUILD_WITH_INSTALL_RPATH

cmake --build . --config Release --parallel ${CPU_COUNT} --verbose || exit 1
cmake --install . || exit 1
rm -rf $SRC_DIR/build

# Install MeTA package
cd ${SRC_DIR} || exit 1
${PYTHON} -m pip install . --no-deps -vv || exit 1
