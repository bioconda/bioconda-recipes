#!/bin/bash
set -ex
pushd tools/utils
./configure --with-htslib=${PREFIX}
ls
popd
pushd tools
make setup _utils CC=${CC}
ls -la
popd

python -m pip install . -vv --no-deps --install-option="--minimal"
