#!/bin/bash
set -e

mkdir -p build
pushd build
cmake -DCXXAPI=ON .. -DCMAKE_INSTALL_PREFIX=.
make
popd

"${PYTHON}" -m pip install . --no-deps --ignore-installed -vv

