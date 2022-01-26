#!/bin/bash
set -ex
pushd tools
make
popd
#pushd tools
#make setup _utils CC=${CC} LDFLAGS="${LDFLAGS}"
#popd

python -m pip install . -vv --no-deps --install-option="--minimal"
