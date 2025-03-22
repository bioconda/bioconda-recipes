#!/usr/bin/env bash

set -xe

mkdir build
cd build

cmake \
-DLIBLEMON_ROOT=${PREFIX} \
-DCMAKE_BUILD_TYPE=RELEASE \
-DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
../src/decifer/cpp/

make -j ${CPU_COUNT} VERBOSE=1
cp mergestatetrees $PREFIX/bin
cp generatestatetrees $PREFIX/bin

cd ..
$PYTHON -m pip install . --ignore-installed --no-deps -vv

