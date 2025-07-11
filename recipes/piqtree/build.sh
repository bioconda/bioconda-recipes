#!/usr/bin/env bash

mkdir -p "${BUILD_PREFIX}/fakebin"
ln -sf "$(which llvm-ar)" "${BUILD_PREFIX}/fakebin/ar"
export PATH="${BUILD_PREFIX}/fakebin:${PATH}"

./build_tools/build_iqtree.sh

python setup.py install