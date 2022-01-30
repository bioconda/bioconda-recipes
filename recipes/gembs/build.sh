#!/bin/bash
set -ex
pushd tools
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
echo ${target_platform}
echo Look over here jake!
make CC="${CC}" LDFLAGS="${LDFLAGS}"
popd
#pushd tools
#make setup _utils CC=${CC} LDFLAGS="${LDFLAGS}"
#popd

python -m pip install . -vv --no-deps --install-option="--minimal"
