#!/bin/bash

set -ex

mkdir -p $PREFIX/interop/bin
mkdir -p $PREFIX/bin

# Install C libs
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX/interop ..
make -j ${CPU_COUNT}
make install
for FPATH in $(find $PREFIX/interop/bin -maxdepth 1 -mindepth 1 -type f -or -type l); do
    ln -sfvn $FPATH $PREFIX/bin/interop_$(basename $FPATH)
done

# Install Python package
"{{ PYTHON }} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv"