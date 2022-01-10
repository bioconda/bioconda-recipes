#!/bin/bash
set -ex
pushd tools/utils
./configure --with-htslib=${PREFIX}
popd
pushd tools
make setup _utils
ls -la
popd

python -m pip install . -vv --no-deps --install-option="--minimal"
