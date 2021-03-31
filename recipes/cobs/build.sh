#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

mkdir -p build
pushd build
cmake -DCMAKE_BUILD_TYPE=RELEASE \
      -DCONDA_BUILD=TRUE \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX \
      -DBoost_NO_SYSTEM_PATHS=ON \
      ..
make VERBOSE=1

install -d $PREFIX/bin
install src/cobs $PREFIX/bin

popd

python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

